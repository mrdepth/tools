//
//  NSArray+Hash.m
//  EVEOnlineAPI
//
//  Created by Artem Shimanski on 25.11.16.
//
//

#import "NSArray+Hash.h"
#include <functional>

inline void hash_combine(std::size_t& seed) { }

template <typename T, typename... Rest>
inline void hash_combine(std::size_t& seed, const T& v, Rest... rest) {
	std::hash<T> hasher;
	seed ^= hasher(v) + 0x9e3779b9 + (seed<<6) + (seed>>2);
	hash_combine(seed, rest...);
}

@implementation NSArray (Hash)

- (NSUInteger) fullHash {
	std::size_t seed = 1;
	for (id value in self) {
		if ([value respondsToSelector:@selector(fullHash)])
			hash_combine(seed, [value fullHash]);
		else
			hash_combine(seed, [value hash]);
	}
	return seed;
}

@end
