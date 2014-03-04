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
				NSData* endMark = [[NSString stringWithFormat:@"\r\n--%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding];
				NSData* delimiter = [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
				NSData* crlf = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
				
				NSMutableData* body = [self.HTTPBody mutableCopy];
				
				NSRange range = [body rangeOfData:endMark options:NSDataSearchBackwards range:NSMakeRange(0, body.length)];
				NSUInteger length = body.length;
				if (range.location != NSNotFound) {
					range.length = length = range.location;
					range.location = 0;
				}
				
				while (range.length > 0) {
					NSRange delimiterRange = [body rangeOfData:delimiter options:0 range:range];
					NSRange dataRange = range;
					if (delimiterRange.location != NSNotFound)
						dataRange.length = delimiterRange.location - range.location;
					NSRange crlfRange = [body rangeOfData:crlf options:0 range:dataRange];
					if (crlfRange.location != NSNotFound) {
						NSRange headerRange = NSMakeRange(dataRange.location, crlfRange.location - dataRange.location);
						NSRange valueRange;
						valueRange.location = crlfRange.location + crlfRange.length;
						valueRange.length = dataRange.location + dataRange.length - valueRange.location;

						NSString* headersString = [[NSString alloc] initWithData:[body subdataWithRange:headerRange] encoding:NSUTF8StringEncoding];
						NSDictionary* headers = [headersString httpHeaders];
						NSString* contentDisposition = headers[@"Content-Disposition"];
						NSDictionary* valueFields = [contentDisposition httpHeaderValueFields];
						NSString* name = valueFields[@"name"];
						NSString* fileName = valueFields[@"filename"];
						if (name) {
							if (fileName)
								dic[name] = @{@"fileName": fileName, @"value": [body subdataWithRange:valueRange]};
							else {
								NSString* value = [[NSString alloc] initWithData:[body subdataWithRange:valueRange] encoding:NSUTF8StringEncoding];
								if (value)
									dic[name] = value;
							}
						}

						
					}
					if (delimiterRange.location != NSNotFound)
						range.location = delimiterRange.location + delimiterRange.length;
					else
						range.location = dataRange.location + dataRange.length;
					range.length = length - range.location;
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
