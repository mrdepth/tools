//
//  NSString+ASHTTPServer.m
//  Neocom
//
//  Created by Артем Шиманский on 18.02.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import "NSString+ASHTTPServer.h"

@implementation NSString (ASHTTPServer)

- (NSDictionary*) httpHeaderValueFields {
	NSArray* fields = [self componentsSeparatedByString:@";"];
	NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:fields.count];
	
	for (NSString* field in fields) {
		NSArray* components = [field componentsSeparatedByString:@"="];
		if (components.count == 2) {
			NSString* key = [components[0] stringByReplacingOccurrencesOfString:@" " withString:@""];
			NSString* value = [components[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
			dic[[key lowercaseString]] = value;
		}
	}
	return dic;
}

- (NSDictionary*) httpHeaders {
	NSArray* headers = [self componentsSeparatedByString:@"\r\n"];
	NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:headers.count];
	
	for (NSString* header in headers) {
		NSArray* components = [header componentsSeparatedByString:@":"];
		if (components.count == 2) {
			NSString* key = components[0];
			NSString* value = components[1];
			dic[key] = value;
		}
	}
	return dic;
}

- (NSDictionary*) httpGetArguments {
	NSArray* arguments = [self componentsSeparatedByString:@"&"];
	NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:arguments.count];
	for (NSString *argument in arguments) {
		NSArray *components = [argument componentsSeparatedByString:@"="];
		if (components.count == 2) {
			NSString* key = components[0];
			NSString *value = [components[1] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
			value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			dic[key] = value;
		}
	}
	return dic;
}

@end
