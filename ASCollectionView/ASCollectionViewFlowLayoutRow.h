//
//  ASCollectionViewFlowLayoutRow.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASCollectionViewFlowLayoutItem.h"

@class ASCollectionViewFlowLayoutSection;
@interface ASCollectionViewFlowLayoutRow : NSObject<NSCopying>
@property (nonatomic, weak) ASCollectionViewFlowLayoutSection* section;
@property (nonatomic, strong, readonly) NSMutableArray* items;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) BOOL lastRow;

- (void) addItem:(ASCollectionViewFlowLayoutItem*) item;
- (void) layout;

@end
