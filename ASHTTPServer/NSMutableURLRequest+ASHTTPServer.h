//
//  NSMutableURLRequest+ASHTTPServer.h
//  Neocom
//
//  Created by Артем Шиманский on 21.01.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (ASHTTPServer)

- (id) initWithHTTPMessage:(CFHTTPMessageRef) message;

@end
