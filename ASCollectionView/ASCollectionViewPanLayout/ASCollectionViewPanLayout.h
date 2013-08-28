//
//  ASCollectionViewPanLayout.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 06.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewFlowLayout.h"
#import "ASCollectionView.h"

@protocol ASCollectionViewDelegatePanLayout<ASCollectionViewDelegateFlowLayout>
@optional
- (BOOL)collectionView:(ASCollectionView *)collectionView canPanItemsAtIndexPaths:(NSArray*) indexPaths;
- (BOOL)collectionView:(ASCollectionView *)collectionView canMoveItemsAtIndexPaths:(NSArray*) indexPaths toIndexPaths:(NSArray*) destination;
- (BOOL)collectionView:(ASCollectionView *)collectionView canPutItemsAtIndexPaths:(NSArray*) indexPaths toItemAtIndexPath:(NSIndexPath*) indexPath;

- (void)collectionView:(ASCollectionView *)collectionView didMoveItemsAtIndexPaths:(NSArray*) indexPaths toIndexPaths:(NSArray*) destination;
- (void)collectionView:(ASCollectionView *)collectionView didPutItemsAtIndexPaths:(NSArray*) indexPaths toItemAtIndexPath:(NSIndexPath*) indexPath;

@end

@interface ASCollectionViewPanLayout : ASCollectionViewFlowLayout
@property (nonatomic, assign) BOOL allowsMultiplePan;

- (UIView*) panViewContainer;

@end
