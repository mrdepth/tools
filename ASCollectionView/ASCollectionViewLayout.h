//
//  ASCollectionViewLayout.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASCollectionViewLayoutAttributes.h"

@class ASCollectionView;
@interface ASCollectionViewLayout : NSObject
@property (nonatomic, weak, readonly) ASCollectionView *collectionView;

- (void)invalidateLayout;

+ (Class)layoutAttributesClass;
- (void)prepareLayout;

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
- (ASCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (ASCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (ASCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionViewContentSize;

//UpdateSupportHooks

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems;
- (void)finalizeCollectionViewUpdates;

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds;
- (void)finalizeAnimatedBoundsChange;

- (ASCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
- (ASCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
- (ASCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath;
- (ASCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath;
- (ASCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath;
- (ASCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath;

@end
