//
//  ASValueTransformer.m
//  ASBinding
//
//  Created by Artem Shimanski on 23.11.16.
//  Copyright © 2016 Artem Shimanski. All rights reserved.
//

#import "ASValueTransformer.h"

@interface ASValueTransformer()
@property (nonatomic, copy) id(^handler)(id value);

@end

@implementation ASValueTransformer

+ (BOOL) allowsReverseTransformation {
	return NO;
}

+ (instancetype) valueTransformerWithHandler:(id(^)(id value)) block {
	return [[self alloc] initWithHandler:block];
}

- (instancetype) initWithHandler:(id(^)(id value)) block {
	if (self = [super init]) {
		self.handler = block;
	}
	return self;
}

- (id) transformedValue:(id)value {
	return self.handler(value);
}

@end
