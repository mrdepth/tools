//
//  NSHTTPURLResponse+ASHTTPServer.m
//  Neocom
//
//  Created by Артем Шиманский on 21.01.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import "NSHTTPURLResponse+ASHTTPServer.h"
#import <objc/runtime.h>

@implementation NSHTTPURLResponse (ASHTTPServer)

-(id)initWithURL:(NSURL*) url statusCode:(NSInteger) statusCode bodyData:(NSData*) bodyData headerFields:(NSDictionary*) headerFields {
	if (!headerFields[@"Content-Length"]) {
		NSMutableDictionary* mutableHeaderFields = [[NSMutableDictionary alloc] initWithDictionary:headerFields];
		mutableHeaderFields[@"Content-Length"] = [NSString stringWithFormat:@"%d", bodyData.length];
		headerFields = mutableHeaderFields;
	}

	if (self = [self initWithURL:url statusCode:statusCode HTTPVersion:(__bridge NSString*) kCFHTTPVersion1_1 headerFields:headerFields]) {
		if (bodyData)
			objc_setAssociatedObject(self, @"bodyData", bodyData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return self;
}

- (NSData*) bodyData {
	return objc_getAssociatedObject(self, @"bodyData");
}

@end
