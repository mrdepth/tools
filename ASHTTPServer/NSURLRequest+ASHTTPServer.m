//
//  NSURLRequest+ASHTTPServer.m
//  Neocom
//
//  Created by Артем Шиманский on 18.02.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import "NSURLRequest+ASHTTPServer.h"
#import "NSString+ASHTTPServer.h"
#import <objc/runtime.h>

@interface NSURLRequest()
@property (nonatomic, strong, readwrite) NSDictionary* arguments;

@end

@implementation NSURLRequest (ASHTTPServer)

- (NSDictionary*) arguments {
	NSDictionary* arguments = objc_getAssociatedObject(self, @"arguments");
	if (!arguments) {
		NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
		
		NSString* query = self.URL.query;
		if (query) {
			[dic addEntriesFromDictionary:[query httpGetArguments]];
		}
		NSString* contentType = [self valueForHTTPHeaderField:@"Content-Type"];
		
		if ([contentType rangeOfString:@"application/x-www-form-urlencoded"].location != NSNotFound) {
			query = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
			[dic addEntriesFromDictionary:[query httpGetArguments]];
		}
		else if ([contentType rangeOfString:@"multipart/form-data"].location != NSNotFound) {
			NSDictionary* fields = [contentType httpHeaderValueFields];
			NSString* boundary = fields[@"boundary"];
			
			
			if (boundary) {
				NSString* endMark = [NSString stringWithFormat:@"\r\n--%@--", boundary];
				NSString* delimiter = [NSString stringWithFormat:@"\r\n--%@", boundary];
				NSMutableString* body = [[NSMutableString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
				NSRange range = [body rangeOfString:endMark];
				if (range.location != NSNotFound) {
					range.length = body.length - range.location;
					[body replaceCharactersInRange:range withString:@""];
				}
				
				NSArray* parts = [body componentsSeparatedByString:delimiter];
				
				for (NSString* part in parts) {
					range = [part rangeOfString:@"\r\n\r\n"];
					if (range.location != NSNotFound) {
						NSString* headersString = [part substringToIndex:range.location];
						NSString* value = [part substringFromIndex:range.location + range.length];
						NSDictionary* headers = [headersString httpHeaders];
						NSString* contentDisposition = headers[@"Content-Disposition"];
						NSDictionary* valueFields = [contentDisposition httpHeaderValueFields];
						NSString* name = valueFields[@"name"];
						NSString* fileName = valueFields[@"filename"];
						if (name && value) {
							if (fileName)
								dic[name] = @{@"fileName": fileName, @"value": value};
							else
								dic[name] = value;
						}
					}
				}
			}
		}
		self.arguments = arguments = dic;
	}
	return arguments;
}

- (void) setArguments:(NSDictionary *)arguments {
	objc_setAssociatedObject(self, @"arguments", arguments, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
