//
//  UIColor+NSNumber.m
//  PhotosPlus
//
//  Created by Shimanski on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIColor+NSNumber.h"


@implementation UIColor(NSNumber)

+ (id) colorWithNumber:(NSNumber*) number {
	if (!number)
		return nil;
	NSUInteger rgba = [number unsignedIntegerValue];
	return [self colorWithUInteger:rgba];
}

+ (id) colorWithUInteger:(NSUInteger) rgba {
	float components[4];
	for (int i = 3; i >= 0; i--) {
		components[i] = (rgba & 0xff) / 255.0;
		rgba >>= 8;
	}
	return [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
}

- (NSNumber*) numberValue {
	CGColorRef colorRef = [self CGColor];
	size_t componentsCount = CGColorGetNumberOfComponents(colorRef);
	NSUInteger rgba = 0;
	
	if (componentsCount == 4) {
		const CGFloat *components = CGColorGetComponents(colorRef);
		rgba = 0;
		for (int i = 0; i < 4; i++) {
			rgba <<= 8;
			rgba += (int) (components[i] * 255);
		}
		return [NSNumber numberWithUnsignedInteger:rgba];
	}
	else
		return nil;
}

@end
