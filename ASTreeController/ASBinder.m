//
//  ASBinder.m
//  ASBinding
//
//  Created by Artem Shimanski on 23.11.16.
//  Copyright © 2016 Artem Shimanski. All rights reserved.
//

#import "ASBinder.h"

@class ASBinder;
@interface ASBinding : NSObject
@property (nonatomic, copy) NSString* binding;
@property (nonatomic, copy) NSString* keyPath;
@property (nonatomic, strong) id observable;
@property (nonatomic, weak) id target;
@property (nonatomic, strong) NSValueTransformer* transformer;
@end

@implementation ASBinding
@end

@interface ASBinder()
@property (nonatomic, strong) NSMutableDictionary<NSString*, ASBinding*>* bindings;
@property (nonatomic, weak) id target;
@end


@implementation ASBinder

- (id) initWithTarget:(id) target {
	NSParameterAssert(target);
	if (self = [super init]) {
		self.target = target;
		self.bindings = [NSMutableDictionary new];
	}
	return self;
}

- (void) dealloc {
	[self unbindAll];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
	[self.bindings enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ASBinding * _Nonnull obj, BOOL * _Nonnull stop) {
		if (obj.observable == object && [keyPath isEqualToString:obj.keyPath]) {
			id value = [object valueForKeyPath:keyPath];
			if (obj.transformer)
				value = [obj.transformer transformedValue:value];
			[obj.target setValue:value forKeyPath:obj.binding];
			*stop = YES;
		}
	}];
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath transformer:(__kindof NSValueTransformer*) transformer {
	NSParameterAssert(observable);
	NSParameterAssert(binding);
	NSParameterAssert(keyPath);
	[self unbind:binding];
	
	ASBinding* bind = [ASBinding new];
	bind.binding = binding;
	bind.keyPath = keyPath;
	bind.observable = observable;
	bind.target = self.target;
	bind.transformer = transformer;
	self.bindings[binding] = bind;
	[observable addObserver:self forKeyPath:keyPath options:0 context:nil];
	
	id value = [observable valueForKeyPath:keyPath];
	if (transformer)
		value = [transformer transformedValue:value];

	[self.target setValue:value forKeyPath:binding];
}

- (void) unbind:(NSString*) binding {
	ASBinding* bind = self.bindings[binding];
	if (bind) {
		[bind.observable removeObserver:self forKeyPath:bind.keyPath];
		[self.bindings removeObjectForKey:binding];
	}
}

- (void) unbindAll {
	for (NSString* key in self.bindings.allKeys)
		[self unbind:key];
}

@end
