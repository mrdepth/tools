//
//  NSObject+Debug.m
//  EVEUniverse
//
//  Created by Artem Shimanski on 03.09.13.
//
//

#import "NSObject+Debug.h"
#import <objc/runtime.h>

@implementation NSObject (Debug)

+ (NSArray*) allMethods {
	unsigned int count = 0;
	Method* m = class_copyMethodList(self, &count);
	
	NSMutableArray* array = [NSMutableArray new];
	for (unsigned int i = 0; i < count; i++) {
		NSString* s = [NSString stringWithCString:sel_getName(method_getName(m[i])) encoding:NSUTF8StringEncoding];
		[array addObject:s];
	}
	[array sortUsingSelector:@selector(compare:)];
	free(m);
	return array;
}

+ (NSArray*) allProperties {
	unsigned int count = 0;
	objc_property_t* p = class_copyPropertyList(self, &count);
	
	NSMutableArray* array = [NSMutableArray new];
	for (unsigned int i = 0; i < count; i++) {
		NSString* s = [NSString stringWithCString:property_getName(p[i]) encoding:NSUTF8StringEncoding];
		[array addObject:s];
	}
	[array sortUsingSelector:@selector(compare:)];
	free(p);
	return array;
}

+ (NSArray*) allIvars {
	unsigned int count = 0;
	Ivar* ivars = class_copyIvarList(self, &count);
	
	NSMutableArray* array = [NSMutableArray new];
	for (unsigned int i = 0; i < count; i++) {
		NSString* s = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding];
		[array addObject:s];
	}
	[array sortUsingSelector:@selector(compare:)];
	free(ivars);
	return array;
}

@end
