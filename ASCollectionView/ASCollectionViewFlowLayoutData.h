//
//  ASCollectionViewFlowLayoutData.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASCollectionViewFlowLayoutSection.h"

@class ASCollectionViewFlowLayout;
@class ASCollectionViewLayoutAttributes;
@interface ASCollectionViewFlowLayoutData : NSObject<NSCopying>
@property (nonatomic, weak) ASCollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong, readonly) NSMutableArray* sections;
@property (nonatomic, assign, readonly) CGSize contentSize;
@property (nonatomic, assign) CGFloat dimension;

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
- (ASCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (ASCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (ASCollectionViewLayoutAttributes *)layoutAttributesForPlaceholderInSection:(NSInteger) section;

- (void) addSection:(ASCollectionViewFlowLayoutSection*) section;
- (void) layout;
@end
