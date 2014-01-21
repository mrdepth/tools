//
//  ASHTTPServer.h
//  Neocom
//
//  Created by Артем Шиманский on 21.01.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "NSHTTPURLResponse+ASHTTPServer.h"
#import "NSMutableURLRequest+ASHTTPServer.h"

#define ASHTTPServerErrorDomain @"EUHTTPServerErrorDomain"

#define ASHTTPServerErrorNoSocketsAvailable NSLocalizedString(@"No sockets available", nil)
#define ASHTTPServerErrorCouldNotBindToIPv4Address NSLocalizedString(@"Could not bind to IPv4 address", nil)
#define ASHTTPServerErrorCouldNotBindOrEstablishNetService NSLocalizedString(@"Could not bind or establish Net Service", nil)

typedef NS_ENUM(NSInteger, ASHTTPServerErrorCode) {
	ASHTTPServerErrorCodeNoSocketsAvailable = 1,
	ASHTTPServerErrorCodeCouldNotBindToIPv4Address,
	ASHTTPServerErrorCodeCouldNotBindOrEstablishNetService
	
};

typedef NS_ENUM(NSInteger, ASHTTPServerState) {
	ASHTTPServerStateOffline,
	ASHTTPServerStateStarting,
	ASHTTPServerStateRunning,
	ASHTTPServerStateStopping
};

@class ASHTTPServer;
@protocol ASHTTPServerDelegate<NSObject>

- (void) server:(ASHTTPServer*) server didReceiveRequest:(NSURLRequest*) request;

@end

@interface ASHTTPServer : NSObject
@property (nonatomic, assign, readonly) ASHTTPServerState state;
@property (nonatomic, weak) id<ASHTTPServerDelegate> delegate;

- (id) initWithName:(NSString*) name port:(in_port_t) port;
- (BOOL) startWithError:(NSError**) errorPtr;
- (void) stop;
- (void) finishRequest:(NSURLRequest*) request withResponse:(NSHTTPURLResponse*) response;

@end
