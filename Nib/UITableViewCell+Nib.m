//
//  UITableViewCell+Nib.m
//  SettingsKit
//
//  Created by Artem Shimanski on 17.08.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import "UITableViewCell+Nib.h"

@implementation UITableViewCell (Nib)
+ (id) cellWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle reuseIdentifier:(NSString *)reuseIdentifier {
	if (!nibBundle)
		nibBundle = [NSBundle mainBundle];
	NSArray *objects = [nibBundle loadNibNamed:nibName owner:nil options:nil];
	for (NSObject *object in objects) {
		if ([object isKindOfClass:[self class]]) {
			UITableViewCell *cell = (UITableViewCell *) object;
			if ([[cell reuseIdentifier] isEqualToString:reuseIdentifier])
				return cell;
		}
	}
	return nil;
}
@end
