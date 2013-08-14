//
//  ASCollectionViewLayout.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewLayout.h"

@interface ASCollectionViewLayout()
@property (nonatomic, weak, readwrite) ASCollectionView *collectionView;

@end

@implementation ASCollectionViewLayout

- (void)invalidateLayout {
	
}

+ (Class)layoutAttributesClass {
	return [ASCollectionViewLayoutAttributes class];
}

- (void)prepareLayout {
	
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	return nil;
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (CGSize)collectionViewContentSize {
	return CGSizeZero;
}

//UpdateSupportHooks

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
}

- (void)finalizeCollectionViewUpdates {
	
}

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds {
	
}

- (void)finalizeAnimatedBoundsChange {
	
}

- (ASCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	return nil;
}

- (ASCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	return nil;
}

- (ASCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
	return nil;
}

- (ASCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
	return nil;
}

- (ASCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath {
	return nil;
}

- (ASCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath {
	return nil;
}

@end
