//
//  NSDictionary+Hash.m
//  Neocom
//
//  Created by Artem Shimanski on 06.10.16.
//  Copyright © 2016 Artem Shimanski. All rights reserved.
//

#import "NSDictionary+Hash.h"
#include <functional>

inline void hash_combine(std::size_t& seed) { }

template <typename T, typename... Rest>
inline void hash_combine(std::size_t& seed, const T& v, Rest... rest) {
	std::hash<T> hasher;
	seed ^= hasher(v) + 0x9e3779b9 + (seed<<6) + (seed>>2);
	hash_combine(seed, rest...);
}

@implementation NSDictionary (Hash)

- (NSUInteger) fullHash {
	std::size_t seed = 1;
	for (id key in [self.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
		hash_combine(seed, [key hash]);
		id value = self[key];
		if ([value respondsToSelector:@selector(fullHash)])
			hash_combine(seed, [value fullHash]);
		else
			hash_combine(seed, [value hash]);
	}
	return seed;
}

@end
