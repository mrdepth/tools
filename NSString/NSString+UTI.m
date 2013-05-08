//
//  NSString+UTI.m
//  MyFolder
//
//  Created by Artem Shimanski on 23.05.12.
//  Copyright (c) 2012 Belprog. All rights reserved.
//

#import "NSString+UTI.h"

@implementation NSString (UTI)

- (BOOL) isImageFile {
	NSString* extension = [self pathExtension];
	if (extension) {
#if ! __has_feature(objc_arc)
		NSArray* arr = (NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, (CFStringRef) @"public.image");
		[arr autorelease];
#else
		NSArray* arr = (__bridge_transfer NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) extension, (__bridge CFStringRef) @"public.image");
#endif
		if (arr.count == 1) {
			NSString* uti = [arr objectAtIndex:0];
			return ![uti hasPrefix:@"dyn."];
		}
		else if (arr.count > 1)
			return YES;
		else
			return NO;
	}
	return NO;
}

- (NSString*) fileUTI {
	NSString* extension = [self pathExtension];
	if (extension)
#if ! __has_feature(objc_arc)
		return (NSString*) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, (CFStringRef) @"public.image");
#else
	return (__bridge_transfer NSString*) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) extension, (__bridge CFStringRef) @"public.image");
#endif
	else
		return nil;
}

- (BOOL) isVideoFile {
	NSString* extension = [[self pathExtension] lowercaseString];
	if (extension) {
#if ! __has_feature(objc_arc)
		NSArray* arr = (NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, (CFStringRef) @"public.movie");
		[arr autorelease];
#else
		NSArray* arr = (__bridge_transfer NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) extension, (__bridge CFStringRef) @"public.movie");
#endif
		if (arr.count == 1) {
			NSString* uti = [arr objectAtIndex:0];
			return ![uti hasPrefix:@"dyn."];
		}
		else if (arr.count > 1)
			return YES;
		else
			return NO;
	}
	return NO;
}

- (NSString*) fileMIMEType {
	NSString* extension = [self pathExtension];
	if (extension) {
#if ! __has_feature(objc_arc)
		NSArray* arr = (NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, nil);
		[arr autorelease];
#else
		NSArray* arr = (__bridge_transfer NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) extension, nil);
#endif
		if (arr.count > 0) {
			for (NSString* uti in arr) {
#if ! __has_feature(objc_arc)
				NSString* mime = (NSString*) UTTypeCopyPreferredTagWithClass((CFStringRef) uti, kUTTagClassMIMEType);
				if (mime)
					return [mime autorelease];
#else
				return (__bridge_transfer NSString*) UTTypeCopyPreferredTagWithClass((__bridge CFStringRef) uti, kUTTagClassMIMEType);
#endif
			}
			return nil;
		}
	}
	return NO;
}

@end
