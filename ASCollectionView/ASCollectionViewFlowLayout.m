//
//  ASCollectionViewFlowLayout.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewFlowLayout.h"
#import "ASCollectionViewFlowLayoutData.h"
#import "ASCollectionViewData.h"

@interface ASCollectionView()
@property (nonatomic, strong) NSMutableDictionary* indexesOldToNewMap;
@property (nonatomic, strong) NSMutableDictionary* indexesNewToOldMap;
@property (nonatomic, strong) ASCollectionViewData* collectionViewData;

@end

@interface ASCollectionViewFlowLayout()
@property (nonatomic, strong) ASCollectionViewFlowLayoutData* data;
@property (nonatomic, strong) ASCollectionViewFlowLayoutData* oldData;
@property (nonatomic, strong) NSMutableArray* reloadAppearingIndexes;
@property (nonatomic, strong) NSMutableArray* reloadDisappearingIndexes;
- (void) updateSizeInfo;
- (void) updateItemsLayout;
@end

@implementation ASCollectionViewFlowLayout

- (ASCollectionViewLayoutAttributes *)layoutAttributesForPlaceholderInSection:(NSInteger) section {
	if (!_data)
		[self prepareLayout];
	return [_data layoutAttributesForPlaceholderInSection:section];
}

- (void) invalidateLayout {
	self.data = nil;
}

- (void) prepareLayout {
	self.data = [ASCollectionViewFlowLayoutData new];
	self.data.flowLayout = self;
	self.data.dimension = self.collectionView.bounds.size.width;
	
	[self updateSizeInfo];
	[self updateItemsLayout];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	if (!_data)
		[self prepareLayout];
	return [_data layoutAttributesForElementsInRect:rect];
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (!_data)
		[self prepareLayout];
	return [_data layoutAttributesForItemAtIndexPath:indexPath];
};

- (ASCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if (!_data)
		[self prepareLayout];
	return [_data layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
}

- (CGSize)collectionViewContentSize {
	if (!_data)
		[self prepareLayout];
	return _data.contentSize;
}

//UpdateSupportHooks

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
	self.oldData = self.data;
	self.reloadAppearingIndexes = [NSMutableArray new];
	self.reloadDisappearingIndexes = [NSMutableArray new];
	
	for (ASCollectionViewUpdateItem* updateItem in updateItems) {
		if (updateItem.updateAction == ASCollectionUpdateActionReload) {
			[_reloadDisappearingIndexes addObject:updateItem.indexPathBeforeUpdate];
			[_reloadAppearingIndexes addObject:updateItem.indexPathAfterUpdate];
		}
	}

	[self.collectionView.collectionViewData invalidate];
	[self prepareLayout];
}

- (void)finalizeCollectionViewUpdates {
	self.oldData = nil;
}

- (ASCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	NSIndexPath* indexPath = self.collectionView.indexesNewToOldMap[itemIndexPath];
	if ([indexPath isKindOfClass:[NSIndexPath class]] && ![self.reloadAppearingIndexes containsObject:itemIndexPath])
		return [_oldData layoutAttributesForItemAtIndexPath:indexPath];
	else
		return nil;
}

- (ASCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	NSIndexPath* indexPath = self.collectionView.indexesOldToNewMap[itemIndexPath];
	if ([indexPath isKindOfClass:[NSIndexPath class]] && ![self.reloadDisappearingIndexes containsObject:itemIndexPath])
		return [_data layoutAttributesForItemAtIndexPath:indexPath];
	else
		return nil;
}

- (ASCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
	if ([elementKind isEqualToString:ASCollectionElementKindSectionSplit]) {
		ASCollectionViewLayoutAttributes* attributes = [self.data layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
		CGRect frame = attributes.frame;
		frame.size.height = 1;
		attributes.frame = frame;
		return attributes;
	}
	else
		return nil;
}

- (ASCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
	if ([elementKind isEqualToString:ASCollectionElementKindSectionSplit]) {
		if ([self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath])
			return nil;
		
		ASCollectionViewLayoutAttributes* attributes = [self.oldData layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
		if (attributes) {
			CGRect frame = attributes.frame;
			frame.size.height = 1;
			attributes.frame = frame;
		}
		return attributes;
	}
	else
		return nil;
}

#pragma mark - ASCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
		return [delegate collectionView:collectionView layout:self sizeForItemAtIndexPath:indexPath];
	else
		return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)])
		return [delegate collectionView:collectionView layout:self insetForSectionAtIndex:section];
	else
		return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)])
		return [delegate collectionView:collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
	else
		return 0;
}

- (CGFloat)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)])
		return [delegate collectionView:collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
	else
		return 0;
}

- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)])
		return [delegate collectionView:collectionView layout:self referenceSizeForHeaderInSection:section];
	else
		return CGSizeZero;
}

- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)])
		return [delegate collectionView:collectionView layout:self referenceSizeForFooterInSection:section];
	else
		return CGSizeZero;
}

- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForSplitInSection:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForSplitInSection:)])
		return [delegate collectionView:collectionView layout:self referenceSizeForSplitInSection:section];
	else
		return CGSizeZero;
}

- (NSIndexPath*) collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceIndexPathForSplitInSection:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:referenceIndexPathForSplitInSection:)])
		return [delegate collectionView:collectionView layout:self referenceIndexPathForSplitInSection:section];
	else
		return nil;
}

- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForPlaceholderInSection:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForPlaceholderInSection:)])
		return [delegate collectionView:collectionView layout:self referenceSizeForPlaceholderInSection:section];
	else
		return CGSizeZero;
}

- (NSIndexPath*) collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceIndexPathForPlaceholderInSection:(NSInteger)section {
	id <ASCollectionViewDelegateFlowLayout> delegate = (id <ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:referenceIndexPathForPlaceholderInSection:)])
		return [delegate collectionView:collectionView layout:self referenceIndexPathForPlaceholderInSection:section];
	else
		return nil;
}


#pragma mark - Private

- (void) updateSizeInfo {
	NSInteger numberOfSections = [self.collectionView numberOfSections];
	for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
		ASCollectionViewFlowLayoutSection* section = [[ASCollectionViewFlowLayoutSection alloc] init];
		
		section.margins = [self collectionView:self.collectionView layout:self insetForSectionAtIndex:sectionIndex];
		section.horizontalInterstice = [self collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIndex];
		section.verticalInterstice = [self collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:sectionIndex];
		
		section.headerDimension = [self collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:sectionIndex].height;
		section.footerDimension = [self collectionView:self.collectionView layout:self referenceSizeForFooterInSection:sectionIndex].height;
		section.splitIndexPath = [self collectionView:self.collectionView layout:self referenceIndexPathForSplitInSection:sectionIndex];
		section.splitDimension = [self collectionView:self.collectionView layout:self referenceSizeForSplitInSection:sectionIndex].height;

		NSIndexPath* placeholderIndexPath = [self collectionView:self.collectionView layout:self referenceIndexPathForPlaceholderInSection:sectionIndex];
		if (placeholderIndexPath) {
			ASCollectionViewFlowLayoutItem* placeholderItem = [ASCollectionViewFlowLayoutItem new];
			placeholderItem.indexPath = placeholderIndexPath;
			placeholderItem.frame = (CGRect){.size = [self collectionView:self.collectionView layout:self referenceSizeForPlaceholderInSection:sectionIndex]};
			section.placeholderItem = placeholderItem;
		}

		NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:sectionIndex];

		for (NSInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
			ASCollectionViewFlowLayoutItem* item = [ASCollectionViewFlowLayoutItem new];
			NSIndexPath* indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
			item.indexPath = indexPath;
			item.frame = (CGRect){.size = [self collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath]};
			[section addItem:item];
		}
		
		[_data addSection:section];
	}
}

- (void) updateItemsLayout {
	[self.data layout];
}

@end
