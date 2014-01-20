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
	Method m2 = class_getInstanceMethod(self, @selector(neocomInstantiateViewControllerWithIdentifier:));
	method_exchangeImplementations(m1, m2);
}

- (id)neocomInstantiateViewControllerWithIdentifier:(NSString *)identifier {
	id viewController = [self neocomInstantiateViewControllerWithIdentifier:identifier];
	NSString* storyboardName = [viewController storyboardName];
	if (storyboardName)
		viewController = [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:identifier];
	return viewController;
}

@end
