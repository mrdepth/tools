//
//  NSMutableURLRequest+ASHTTPServer.m
//  Neocom
//
//  Created by Артем Шиманский on 21.01.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import "NSMutableURLRequest+ASHTTPServer.h"

@implementation NSMutableURLRequest (ASHTTPServer)

- (id) initWithHTTPMessage:(CFHTTPMessageRef) message {
	if (self = [super initWithURL:(__bridge_transfer NSURL*) CFHTTPMessageCopyRequestURL(message)]) {
		self.HTTPMethod = (__bridge_transfer NSString*) CFHTTPMessageCopyRequestMethod(message);
		self.HTTPBody = (__bridge_transfer NSData*) CFHTTPMessageCopyBody(message);
		self.allHTTPHeaderFields = (__bridge_transfer NSDictionary*) CFHTTPMessageCopyAllHeaderFields(message);
	}
	return self;
}

@end
