//
//  ASHTTPServer.m
//  Neocom
//
//  Created by Артем Шиманский on 21.01.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import "ASHTTPServer.h"
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif

#import "NSMutableURLRequest+ASHTTPServer.h"
#import <objc/runtime.h>
#import "NSHTTPURLResponse+ASHTTPServer.h"

@interface ASHTTPServer()<NSNetServiceDelegate>
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) in_port_t port;
@property (nonatomic, strong) NSNetService * netService;
@property (assign) CFSocketRef ipv4socket;
@property (nonatomic, strong) NSMutableDictionary* requests;
@property (nonatomic, strong) NSFileHandle* listeningFileHandle;
@property (nonatomic, assign, readwrite) ASHTTPServerState state;

- (void) didReceiveIncommingConnection:(NSNotification*) notification;
- (void) didReceiveData:(NSNotification*) notification;
- (void) stopReceivingForFileHandle:(NSFileHandle *)fileHandle close:(BOOL)close;

@end

@implementation ASHTTPServer

- (id) initWithName:(NSString*) name port:(in_port_t) port {
	if (self = [super init]) {
		self.name = name;
		self.port = port;
		self.requests = [NSMutableDictionary new];
	}
	return self;
}

- (void) dealloc {
	[self stop];
}

- (BOOL) startWithError:(NSError**) errorPtr {
	if (self.state == ASHTTPServerStateRunning)
		return YES;
	
	self.state = ASHTTPServerStateStarting;
	uint16_t chosenPort = 0;
	struct sockaddr_in serverAddress;
	socklen_t nameLen = 0;
	nameLen = sizeof(serverAddress);
	
	if (self.netService && _ipv4socket) {
		return YES;
	} else {
		
		if (!_ipv4socket) {
			_ipv4socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);
			
			if (!_ipv4socket) {
				if (errorPtr)
					*errorPtr = [[NSError alloc] initWithDomain:ASHTTPServerErrorDomain
														   code:ASHTTPServerErrorCodeNoSocketsAvailable
													   userInfo:@{NSLocalizedDescriptionKey: ASHTTPServerErrorNoSocketsAvailable}];
				[self stop];
				self.state = ASHTTPServerStateOffline;
				return NO;
			}
			
			int reuse = 1;
			CFSocketNativeHandle socketDescriptor = CFSocketGetNative(_ipv4socket);
			
			setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEADDR, (void *)&reuse, sizeof(reuse));
			
			// set up the IPv4 endpoint; use port 0, so the kernel will choose an arbitrary port for us, which will be advertised using Bonjour
			memset(&serverAddress, 0, sizeof(serverAddress));
			serverAddress.sin_len = nameLen;
			serverAddress.sin_family = AF_INET;
			serverAddress.sin_port = htons(self.port);
			serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
			NSData * address4 = [NSData dataWithBytes:&serverAddress length:nameLen];
			
			if (kCFSocketSuccess != CFSocketSetAddress(_ipv4socket, (__bridge CFDataRef)address4)) {
				if (errorPtr)
					*errorPtr = [[NSError alloc] initWithDomain:ASHTTPServerErrorDomain
														code:ASHTTPServerErrorCodeCouldNotBindToIPv4Address
													userInfo:@{NSLocalizedDescriptionKey: ASHTTPServerErrorCouldNotBindToIPv4Address}];
				if (_ipv4socket)
					CFRelease(_ipv4socket);
				_ipv4socket = NULL;
				self.state = ASHTTPServerStateOffline;
				return NO;
			}
			
			NSData * addr = (__bridge_transfer NSData *)CFSocketCopyAddress(_ipv4socket);
			memcpy(&serverAddress, [addr bytes], [addr length]);
			chosenPort = ntohs(serverAddress.sin_port);
			
			self.listeningFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:socketDescriptor closeOnDealloc:YES];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(didReceiveIncommingConnection:)
														 name:NSFileHandleConnectionAcceptedNotification
													   object:nil];
			[self.listeningFileHandle acceptConnectionInBackgroundAndNotify];
		}
		
		if (!self.netService && _ipv4socket) {
			self.netService = [[NSNetService alloc] initWithDomain:@"local" type:@"_http._tcp" name:self.name port:chosenPort];
			[self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[self.netService publish];
		}
		
		if (!self.netService && !_ipv4socket) {
			if (errorPtr)
				*errorPtr = [[NSError alloc] initWithDomain:ASHTTPServerErrorDomain
													code:ASHTTPServerErrorCodeCouldNotBindOrEstablishNetService
												userInfo:@{NSLocalizedDescriptionKey: ASHTTPServerErrorCouldNotBindOrEstablishNetService}];
			[self stop];
			return NO;
		}
	}
	self.state = ASHTTPServerStateRunning;
	return YES;
}

- (void) stop {
	if (self.state == ASHTTPServerStateOffline)
		return;
	
	self.state = ASHTTPServerStateStopping;

	[self.netService stop];
	[self.netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	self.netService = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:nil];
	[self.listeningFileHandle closeFile];
	self.listeningFileHandle = nil;
	
	for (NSValue* value in [self.requests allKeys]){
		NSFileHandle* fileHandle = [value nonretainedObjectValue];
		[self stopReceivingForFileHandle:fileHandle close:YES];
	}
	
	if (_ipv4socket)
		CFRelease(_ipv4socket);
	_ipv4socket = NULL;

	
	self.state = ASHTTPServerStateOffline;
}

- (void) finishRequest:(NSURLRequest *)request withResponse:(NSHTTPURLResponse *)response {
	NSFileHandle* fileHandle = objc_getAssociatedObject(request, @"fileHandle");
	CFHTTPMessageRef message = CFHTTPMessageCreateResponse(NULL, response.statusCode, NULL, kCFHTTPVersion1_1);
	
	[[response allHeaderFields] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
		CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef) key, (__bridge CFStringRef) value);
	}];
	
	NSData* bodyData = response.bodyData;
	if (bodyData.length > 0)
		CFHTTPMessageSetBody(message, (__bridge CFDataRef) bodyData);
	
	NSData* data = (__bridge_transfer NSData*) CFHTTPMessageCopySerializedMessage(message);
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		@autoreleasepool {
			[fileHandle writeData:data];
		}
	});
	
	CFRelease(message);
}

#pragma mark NSNetServiceDelegate

- (void)netServiceDidPublish:(NSNetService *)sender {
    self.netService = sender;
}

#pragma mark - Private

- (void) didReceiveIncommingConnection:(NSNotification*) notification {
	NSFileHandle *incomingFileHandle = notification.userInfo[NSFileHandleNotificationFileHandleItem];
	
    if(incomingFileHandle)
	{
		self.requests[[NSValue valueWithNonretainedObject:incomingFileHandle]] = (__bridge_transfer id) CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didReceiveData:)
													 name:NSFileHandleDataAvailableNotification
												   object:incomingFileHandle];
		
        [incomingFileHandle waitForDataInBackgroundAndNotify];
    }
	
	[self.listeningFileHandle acceptConnectionInBackgroundAndNotify];
}

- (void) didReceiveData:(NSNotification*) notification {
	NSFileHandle *incomingFileHandle = [notification object];
	NSData *data = [incomingFileHandle availableData];
	
	if ([data length] == 0)
	{
		[self stopReceivingForFileHandle:incomingFileHandle close:NO];
		return;
	}
	
	CFHTTPMessageRef incomingRequest = (__bridge CFHTTPMessageRef) self.requests[[NSValue valueWithNonretainedObject:incomingFileHandle]];
	
	if (!incomingRequest) {
		[self stopReceivingForFileHandle:incomingFileHandle close:YES];
		return;
	}
	
	if (!CFHTTPMessageAppendBytes(incomingRequest, [data bytes], [data length])) {
		
		[self stopReceivingForFileHandle:incomingFileHandle close:YES];
		return;
	}
	
	if(CFHTTPMessageIsHeaderComplete(incomingRequest)) {
		NSInteger contentLength = [(__bridge_transfer NSString*) CFHTTPMessageCopyHeaderFieldValue(incomingRequest, CFSTR("Content-Length")) integerValue];
		if (contentLength > 0) {
			NSData* body = (__bridge_transfer NSData*) CFHTTPMessageCopyBody(incomingRequest);
			if (body.length >= contentLength) {
				NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithHTTPMessage:incomingRequest];
				[self stopReceivingForFileHandle:incomingFileHandle close:NO];
				objc_setAssociatedObject(request, @"fileHandle", incomingFileHandle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
				[self.delegate server:self didReceiveRequest:request];
				return;
			}
		}
		else {
			NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithHTTPMessage:incomingRequest];
			[self stopReceivingForFileHandle:incomingFileHandle close:NO];
			objc_setAssociatedObject(request, @"fileHandle", incomingFileHandle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			[self.delegate server:self didReceiveRequest:request];
			return;
		}
	}
	
	[incomingFileHandle waitForDataInBackgroundAndNotify];
}

- (void) stopReceivingForFileHandle:(NSFileHandle *)fileHandle close:(BOOL)close {
	if (close)
		[fileHandle closeFile];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:fileHandle];
	[self.requests removeObjectForKey:[NSValue valueWithNonretainedObject:fileHandle]];
}

@end
