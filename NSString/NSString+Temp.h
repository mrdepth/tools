//
//  NSString+Temp.h
//  Neocom
//
//  Created by Артем Шиманский on 05.03.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Temp)

+ (instancetype) temporaryFilePathWithExtension:(NSString*) extension;

@end
