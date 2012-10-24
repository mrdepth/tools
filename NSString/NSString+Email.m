//
//  NSString+Email.m
//  MyFolder
//
//  Created by Artem Shimanski on 08.08.12.
//
//

#import "NSString+Email.h"

@implementation NSString (Email)

- (BOOL) isValidEmailString {
	NSError* error = nil;
	NSRegularExpression* expr = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
																		  options:0
																			error:&error];
	NSRange range = NSMakeRange(0, self.length);
	NSRange matchRange = [expr rangeOfFirstMatchInString:self options:0 range:range];
	return NSEqualRanges(range, matchRange);
}

@end
