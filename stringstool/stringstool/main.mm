//
//  main.m
//  stringstool
//
//  Created by Artem Shimanski on 14.12.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

NSMutableDictionary* getStrings(NSString* filePath) {
	NSError* error = nil;
	//NSString* fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16StringEncoding error:&error];
	NSStringEncoding encoding;
	NSString* fileContent = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
//	if (encoding != NSUTF8StringEncoding) {
//		fileContent = [NSString stringWithCString:[fileContent UTF8String] encoding:NSUTF8StringEncoding];
//	}
	
	NSMutableDictionary* strings = [NSMutableDictionary dictionary];
	for (NSString* line in [fileContent componentsSeparatedByString:@"\n"]) {
		wchar_t* s = (wchar_t*) [line cStringUsingEncoding:NSUTF32StringEncoding];
		int keyStart = -1;
		int keyEnd = -1;
		int valueStart = -1;
		int valueEnd = -1;
		
		for (int i = 0; s[i]; i++) {
			if (s[i] == L'\\') {
				i++;
			}
			else if (s[i] == L'"') {
				if (keyStart == -1)
					keyStart = i + 1;
				else if (keyEnd == -1)
					keyEnd = i;
				else if (valueStart == -1)
					valueStart = i + 1;
				else if (valueEnd == -1)
					valueEnd = i;
			}
		}
		if (keyEnd > keyStart && valueEnd > valueStart) {
			NSString* key = [line substringWithRange:NSMakeRange(keyStart, keyEnd - keyStart)];
			NSString* value = [line substringWithRange:NSMakeRange(valueStart, valueEnd - valueStart)];
			[strings setValue:value forKey:key];
		}
	}
	return strings;
}

NSString* getString(NSDictionary* strings) {
	NSMutableArray* rows = [NSMutableArray array];
	for (NSString* key in [strings allKeys]) {
		NSString* value = strings[key];
		if ([value isKindOfClass:[NSString class]])
			[rows addObject:[NSString stringWithFormat:@"\"%@\" = \"%@\";", key, value]];
		else
			[rows addObject:[NSString stringWithFormat:@"\"%@\" = ADD_TRANSLATION;", key]];
	}
	[rows sortUsingSelector:@selector(compare:)];
	return [rows componentsJoinedByString:@"\n"];
}

NSDictionary* parseCommandLine(int argc, const char * argv[]) {
	NSMutableDictionary* args = [NSMutableDictionary dictionary];
	NSString* key = nil;
	
	for (int i = 1; i < argc; i++) {
		const char* s = argv[i];
		if (s[0] == '-') {
			s++;
			if (s[0] == '-')
				s++;
			key = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
			args[key] = @(YES);
		}
		else if (key) {
			if (s[0] != 0) {
				NSString* value = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
				args[key] = value;
			}
		}
	}
	return args;
}

void update(NSString* base, NSString* locale) {
	for (NSString* fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:base error:nil]) {
		if ([fileName hasSuffix:@".strings"]) {
			NSString* inputFileName = [base stringByAppendingPathComponent:fileName];
			NSString* outputFileName = [locale stringByAppendingPathComponent:fileName];
			NSDictionary* input = getStrings(inputFileName);
			NSMutableDictionary* output = getStrings(outputFileName);
			
			NSMutableDictionary* add = [NSMutableDictionary dictionary];
			NSMutableDictionary* pass = [NSMutableDictionary dictionary];
			for (NSString* key in [[input allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
				NSString* value = output[key];
				if (value) {
					pass[key] = value;
					[output removeObjectForKey:key];
				}
				else {
					add[key] = @(YES);
				}
			}
			
			NSString* strings = [NSString stringWithFormat:@"%@\n\n//New Keys\n\n%@\n\n//Unused Keys\n\n%@",
								 getString(pass),
								 getString(add),
								 getString(output)
								 ];
			[strings writeToFile:outputFileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}
	}
}

int main(int argc, const char * argv[])
{
	@autoreleasepool {
		NSDictionary* args = parseCommandLine(argc, argv);
		if (args[@"merge"]) {
			NSMutableDictionary* input = getStrings(args[@"i"]);
			NSMutableDictionary* output = getStrings(args[@"o"]);
			for (NSString* value in [input allValues])
				[output setValue:value forKey:value];
			[getString(output) writeToFile:args[@"o"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}
		else if (args[@"replace"]) {
			NSMutableDictionary* input = getStrings(args[@"i"]);
			NSMutableDictionary* output = getStrings(args[@"o"]);
			for (NSString* key in [output allKeys]) {
				NSString* value = [input valueForKey:key];
				[output setValue:value forKey:key];
			}
			[getString(output) writeToFile:args[@"o"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}
		else if (args[@"update"]) {
			NSString* base = args[@"base"];
			NSString* path = args[@"path"];
			if (!path)
				path = @"./";
			for (NSString* fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil]) {
				if ([fileName hasSuffix:@".lproj"] && ![fileName isEqualToString:base]) {
					update([path stringByAppendingPathComponent:base], [path stringByAppendingPathComponent:fileName]);
				}
			}
		}
	}
    return 0;
}

