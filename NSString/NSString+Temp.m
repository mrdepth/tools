//
//  NSString+Temp.m
//  Neocom
//
//  Created by Артем Шиманский on 05.03.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import "NSString+Temp.h"

@implementation NSString (Temp)

+ (instancetype) temporaryFilePathWithExtension:(NSString*) extension {
	NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"XXXXXX"];
	char* sTemplate = malloc([path lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
	strcpy(sTemplate, [path UTF8String]);
	mktemp(sTemplate);
	path = [NSString stringWithFormat:@"%s.%@", sTemplate, extension];
	free(sTemplate);
	return path;
}


@end
