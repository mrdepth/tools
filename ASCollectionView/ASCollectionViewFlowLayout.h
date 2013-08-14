//
//  ASCollectionViewFlowLayout.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewLayout.h"
#import "ASCollectionView.h"

#define ASCollectionElementKindSectionHeader @"ASCollectionElementKindSectionHeader"
#define ASCollectionElementKindSectionFooter @"ASCollectionElementKindSectionFooter"
#define ASCollectionElementKindSectionSplit  @"ASCollectionElementKindSectionSplit"

@protocol ASCollectionViewDelegateFlowLayout <ASCollectionViewDelegate>
@optional

- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForSplitInSection:(NSInteger)section;
- (NSIndexPath*) collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceIndexPathForSplitInSection:(NSInteger)section;
- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForPlaceholderInSection:(NSInteger)section;
- (NSIndexPath*) collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceIndexPathForPlaceholderInSection:(NSInteger)section;

@end

@interface ASCollectionViewFlowLayout : ASCollectionViewLayout<ASCollectionViewDelegateFlowLayout>
- (ASCollectionViewLayoutAttributes *)layoutAttributesForPlaceholderInSection:(NSInteger) section;

@end
