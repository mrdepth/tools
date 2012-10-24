//
//  UIColor+NSNumber.h
//  PhotosPlus
//
//  Created by Shimanski on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor(NSNumber)

+ (id) colorWithNumber:(NSNumber*) number;
+ (id) colorWithUInteger:(NSUInteger) rgba;
- (NSNumber*) numberValue;

@end
