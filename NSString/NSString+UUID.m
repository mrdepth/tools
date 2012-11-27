//
//  NSString+UUID.m
//  EVEUniverse
//
//  Created by Mr. Depth on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString*) uuidString {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString* string = (__bridge_transfer NSString*) CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
#if ! __has_feature(objc_arc)
	return [string autorelease];
#else
	return string;
#endif
}
@end
