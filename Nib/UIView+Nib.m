//
//  UIView+Nib.m
//  PhotosPlus
//
//  Created by Shimanski on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+Nib.h"


@implementation UIView(Nib)

+ (id) viewWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	if (!nibBundle)
		nibBundle = [NSBundle mainBundle];
	NSArray *objects = [nibBundle loadNibNamed:nibName owner:nil options:nil];
	for (NSObject *object in objects) {
		if ([object isKindOfClass:[self class]]) {
			return object;
		}
	}
	return nil;
}

@end
