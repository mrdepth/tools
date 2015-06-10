//
//  UIStoryboard+Multiple.m
//  Neocom
//
//  Created by Артем Шиманский on 20.01.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import "UIStoryboard+Multiple.h"

#import <objc/runtime.h>

@implementation UIViewController(Multiple)
@dynamic storyboardIdentifier;

- (NSString*) storyboardName {
	return objc_getAssociatedObject(self, @"storyboardName");
}

- (void) setStoryboardName:(NSString *)storyboardName {
	objc_setAssociatedObject(self, @"storyboardName", storyboardName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIStoryboard (Multiple)

+ (void) load {
	Method m1 = class_getInstanceMethod(self, @selector(instantiateViewControllerWithIdentifier:));
	Method m2 = class_getInstanceMethod(self, @selector(multipleInstantiateViewControllerWithIdentifier:));
	method_exchangeImplementations(m1, m2);
}

- (id)multipleInstantiateViewControllerWithIdentifier:(NSString *)identifier {
	id viewController = [self multipleInstantiateViewControllerWithIdentifier:identifier];
	NSString* storyboardName = [viewController storyboardName];
	if (storyboardName) {
		if ([viewController storyboardIdentifier])
			viewController = [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:[viewController storyboardIdentifier]];
		else
			viewController = [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:identifier];
	}
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController* navigationController = viewController;
		if (navigationController.viewControllers.count == 1) {
			UIViewController* viewController = navigationController.viewControllers[0];
			NSString* storyboardName = [viewController storyboardName];
			if (storyboardName) {
				viewController = [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:[viewController storyboardIdentifier]];
				[navigationController setViewControllers:@[viewController] animated:NO];
			}
		}
	}
	return viewController;
}

@end
