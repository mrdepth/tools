//
//  NSBundle+Retina4.m
//  Retina4
//
//  Created by Artem Shimanski on 26.11.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import "NSBundle+Retina4.h"
#import <objc/runtime.h>

@implementation NSBundle (Retina4)

+ (void) load {
	if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0) {
		Method m1 = class_getInstanceMethod(self, @selector(pathForResource:ofType:));
		Method m2 = class_getInstanceMethod(self, @selector(retina4PathForResource:ofType:));
		method_exchangeImplementations(m1, m2);
	}
}

- (NSString *)retina4PathForResource:(NSString *)name ofType:(NSString *)ext {
	NSString* newName = [name stringByAppendingString:@"~568h"];
	NSString* path = [self retina4PathForResource:newName ofType:ext];
	if (path)
		return path;
	return [self retina4PathForResource:name ofType:ext];
}

@end
