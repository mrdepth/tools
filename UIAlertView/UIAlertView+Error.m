//
//  UIAlertView+Error.m
//  
//
//  Created by Artem Shimanski on 9/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+Error.h"


@implementation UIAlertView(Error)

+ (UIAlertView*) alertViewWithError: (NSError*) error {
#if ! __has_feature(objc_arc)
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
#else
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
#endif
	return alertView;
}

@end
