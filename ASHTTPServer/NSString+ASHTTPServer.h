//
//  NSString+ASHTTPServer.h
//  Neocom
//
//  Created by Артем Шиманский on 18.02.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ASHTTPServer)

- (NSDictionary*) httpHeaderValueFields;
- (NSDictionary*) httpHeaders;
- (NSDictionary*) httpGetArguments;

@end
