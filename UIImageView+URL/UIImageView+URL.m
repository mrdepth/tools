//
//  UIImageView+URL.m
//  UIImageView+URL
//
//  Created by Artem Shimanski on 24.08.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import "UIImageView+URL.h"
#import <objc/runtime.h>

static NSOperationQueue* sharedQueue = nil;

@interface URLOperation: NSOperation<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, assign) BOOL ignoreCacheData;
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSHTTPURLResponse* response;
@property (nonatomic, strong) NSData* data;
@property (nonatomic, strong) NSError* error;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, weak) UIImageView* imageView;

@end

@implementation URLOperation


#if ! __has_feature(objc_arc)
- (void) dealloc {
	[_url release];
	[_connection release];
	[_response release];
	[_data release];
	[_error release];
	[_image release];
	[super dealloc];
}
#endif

- (void) main {
	@autoreleasepool {
		NSURLCache* cache = [NSURLCache sharedURLCache];

		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
		NSCachedURLResponse* cachedResponse = [cache cachedResponseForRequest:request];
		if (!self.ignoreCacheData)
			self.data = [cachedResponse data];

		if (!self.data.length) {
			self.data = [NSMutableData data];
			self.loading = YES;
#if ! __has_feature(objc_arc)
			self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES] autorelease];
#else
			self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
#endif
			while (self.loading)
				[[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
			
			if (!self.error && ![self isCancelled]) {
				self.image = [UIImage imageWithData:self.data];
				cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:self.response data:self.data userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
				[cache storeCachedResponse:cachedResponse forRequest:request];
			}
		}
		else
			self.image = [UIImage imageWithData:self.data];
		self.data = nil;
	}
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)aResponse {
	self.response = aResponse;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)aError {
	self.error = aError;
	self.loading = NO;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)aData {
	[(NSMutableData*) self.data appendData:aData];
	if ([self isCancelled]) {
		self.data = nil;
		[aConnection cancel];
		self.loading = NO;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	self.loading = NO;
}

@end


@interface UIImageView()
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@end


@implementation UIImageView (URL)

+ (NSOperationQueue*) sharedQueue {
	@synchronized(self) {
		if (!sharedQueue)
			sharedQueue = [[NSOperationQueue alloc] init];
	}
	return sharedQueue;
}

- (void) setImageWithContentsOfURL: (NSURL*) url {
	[self setImageWithContentsOfURL:url scale:1 ignoreCacheData:NO completion:nil failureBlock:nil];
}

- (void) setImageWithContentsOfURL: (NSURL*) url scale:(float) scale completion:(void(^)()) completion failureBlock:(void(^)(NSError *error)) failureBlock {
	[self setImageWithContentsOfURL:url scale:scale ignoreCacheData:NO completion:completion failureBlock:failureBlock];
}

- (void) setImageWithContentsOfURL: (NSURL*) url scale:(float) scale ignoreCacheData:(BOOL) ignoreCacheData completion:(void(^)()) completion failureBlock:(void(^)(NSError *error)) failureBlock {
#if ! __has_feature(objc_arc)
	__block URLOperation* operation = [[[URLOperation alloc] init] autorelease];
#else
	URLOperation* operation = [[URLOperation alloc] init];
	__weak URLOperation* weakOperation = operation;
#endif
	operation.ignoreCacheData = ignoreCacheData;
	operation.url = url;
	operation.imageView = self;
	
	for (URLOperation* activeOperation in [[UIImageView sharedQueue] operations]) {
		if ([activeOperation.url isEqual:url])
			[operation addDependency:activeOperation];
		else if (activeOperation.imageView == self) {
			[operation addDependency:activeOperation];
			[activeOperation cancel];
		}
	}
	
	[operation setCompletionBlock:^{
#if ! __has_feature(objc_arc)
		URLOperation* strongOperation = operation;
#else
		URLOperation* strongOperation = weakOperation;
#endif
		dispatch_async(dispatch_get_main_queue(), ^{
			if (![strongOperation isCancelled])
				[self.activityIndicatorView stopAnimating];
			
			if (strongOperation.image) {
				self.image = [UIImage imageWithCGImage:[strongOperation.image CGImage] scale:scale orientation:strongOperation.image.imageOrientation];
				if (completion)
					completion();
			}
			else {
				if (failureBlock)
					failureBlock(strongOperation.error);
			}
		});
	}];
	
	[self.activityIndicatorView startAnimating];
	[[UIImageView sharedQueue] addOperation:operation];
}

- (void) cancelAllURLRequests {
	for (URLOperation* activeOperation in [[UIImageView sharedQueue] operations]) {
		if (activeOperation.imageView == self) {
			[activeOperation cancel];
		}
	}
	[self.activityIndicatorView stopAnimating];
}

- (void) setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle {
	objc_setAssociatedObject(self, @"activityIndicatorViewStyle", @(activityIndicatorViewStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	if (activityIndicatorViewStyle == UIActivityIndicatorViewStyleNone) {
		[self.activityIndicatorView removeFromSuperview];
		self.activityIndicatorView = nil;
	}
	else {
		self.activityIndicatorView.activityIndicatorViewStyle = activityIndicatorViewStyle;
	}
}

- (UIActivityIndicatorViewStyle) activityIndicatorViewStyle {
	NSNumber* activityIndicatorViewStyle = objc_getAssociatedObject(self, @"activityIndicatorViewStyle");
	if (activityIndicatorViewStyle)
		return [activityIndicatorViewStyle integerValue];
	else
		return UIActivityIndicatorViewStyleWhite;
}

#pragma mark - Private

- (UIActivityIndicatorView*) activityIndicatorView {
	UIActivityIndicatorView* activityIndicatorView =  objc_getAssociatedObject(self, @"activityIndicatorView");
	if (!activityIndicatorView && self.activityIndicatorViewStyle != UIActivityIndicatorViewStyleNone) {
		activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorViewStyle];
#if ! __has_feature(objc_arc)
		[activityIndicatorView autorelease];
#endif
		activityIndicatorView.hidesWhenStopped = YES;
		activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		activityIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
		[self addSubview:activityIndicatorView];
		self.activityIndicatorView = activityIndicatorView;
	}
	return activityIndicatorView;
}

- (void) setActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView {
	objc_setAssociatedObject(self, @"activityIndicatorView", activityIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
