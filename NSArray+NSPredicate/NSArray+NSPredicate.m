//
//  NSArray+NSPredicate.m
//  EVEOnlineAPI
//
//  Created by Артем Шиманский on 07.08.15.
//
//

#import "NSArray+NSPredicate.h"

@implementation NSArray (NSPredicate)

- (id) objectForKeyedSubscript:(id) key {
	NSPredicate* predicate;
	if ([key isKindOfClass:[NSString class]])
		predicate = [NSPredicate predicateWithFormat:key];
	else if ([key isKindOfClass:[NSPredicate class]])
		predicate = key;
	else
		return nil;
	return [[self filteredArrayUsingPredicate:predicate] lastObject];
}

@end
