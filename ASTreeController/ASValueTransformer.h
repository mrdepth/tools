//
//  ASValueTransformer.h
//  ASBinding
//
//  Created by Artem Shimanski on 23.11.16.
//  Copyright © 2016 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASValueTransformer : NSValueTransformer

+ (instancetype) valueTransformerWithHandler:(id(^)(id value)) block;
- (instancetype) initWithHandler:(id(^)(id value)) block;
@end
