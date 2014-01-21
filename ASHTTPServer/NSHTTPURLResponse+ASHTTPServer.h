//
//  NSHTTPURLResponse+ASHTTPServer.h
//  Neocom
//
//  Created by Артем Шиманский on 21.01.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (ASHTTPServer)
@property (nonatomic, strong, readonly) NSData* bodyData;

-(id)initWithURL:(NSURL*) url statusCode:(NSInteger) statusCode bodyData:(NSData*) bodyData headerFields:(NSDictionary*) headerFields;

@end
