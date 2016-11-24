//
//  ASBinder.h
//  ASBinding
//
//  Created by Artem Shimanski on 23.11.16.
//  Copyright © 2016 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASBinder : NSObject
- (id) initWithTarget:(id) target;
- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath transformer:(__kindof NSValueTransformer*) transformer;
- (void) unbind:(NSString*) binding;
- (void) unbindAll;
@end
