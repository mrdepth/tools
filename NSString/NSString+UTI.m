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
		NSArray* arr = (NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, (CFStringRef) @"public.image");
		[arr autorelease];
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
		return (NSString*) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, (CFStringRef) @"public.image");
	else
		return nil;
}

- (BOOL) isVideoFile {
	NSString* extension = [[self pathExtension] lowercaseString];
	if (extension) {
		NSArray* arr = (NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, (CFStringRef) @"public.movie");
		[arr autorelease];
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
		NSArray* arr = (NSArray*) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, nil);
		[arr autorelease];
		if (arr.count > 0) {
			for (NSString* uti in arr) {
				NSString* mime = (NSString*) UTTypeCopyPreferredTagWithClass((CFStringRef) uti, kUTTagClassMIMEType);
				if (mime)
					return [mime autorelease];
			}
			return nil;
		}
	}
	return NO;
}

@end
