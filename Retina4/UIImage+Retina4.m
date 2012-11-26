//
//  UIImage+Retina4.m
//  Retina4
//
//  Created by Artem Shimanski on 26.11.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import "UIImage+Retina4.h"
#import <objc/runtime.h>

@interface NSBundle ()
- (NSString *)retina4PathForResource:(NSString *)name ofType:(NSString *)ext;
@end


@implementation UIImage (Retina4)

+ (void) initialize {
	if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0) {
		Method m1 = class_getInstanceMethod(NSClassFromString(@"UIImageNibPlaceholder"), @selector(initWithCoder:));
		Method m2 = class_getInstanceMethod(self, @selector(retina4InitWithCoder:));
		method_exchangeImplementations(m1, m2);
		
		Method m3 = class_getClassMethod(self, @selector(imageNamed:));
		Method m4 = class_getClassMethod(self, @selector(retina4ImageNamed:));
		method_exchangeImplementations(m3, m4);
	}
}

- (id) retina4InitWithCoder:(NSCoder *)aDecoder {
	NSString* resourceName = [aDecoder decodeObjectForKey:@"UIResourceName"];
	NSString* extension = [resourceName pathExtension];
	NSString* name = [resourceName stringByDeletingPathExtension];
	if ([name hasPrefix:@"@2x"])
		name = [name substringToIndex:name.length - 3];
	NSString* newResourceName = [name stringByAppendingString:@"~568h"];
	
	NSString* fullPath = [[NSBundle mainBundle] retina4PathForResource:[newResourceName stringByAppendingString:@"@2x"] ofType:extension];
	if (fullPath)
		return [UIImage retina4ImageNamed:[newResourceName stringByAppendingPathExtension:extension]];
	else
		return [self retina4InitWithCoder:aDecoder];
}

+ (UIImage*) retina4ImageNamed:(NSString*) imageName {	
	NSString* extension = [imageName pathExtension];
	NSString* name = [imageName stringByDeletingPathExtension];
	if ([name hasPrefix:@"@2x"])
		name = [name substringToIndex:name.length - 3];
	NSString* newResourceName = [name stringByAppendingString:@"~568h"];
	
	NSString* fullPath = [[NSBundle mainBundle] retina4PathForResource:[newResourceName stringByAppendingString:@"@2x"] ofType:extension];
	if (fullPath)
		return [self retina4ImageNamed:[newResourceName stringByAppendingPathExtension:extension]];
	else
		return [self retina4ImageNamed:imageName];
}

@end
