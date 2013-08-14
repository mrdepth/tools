//
//  ASCollectionViewData.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 31.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASCollectionView;
@interface ASCollectionViewData : NSObject
@property (nonatomic, weak, readonly) ASCollectionView *collectionView;

- (id) initWithCollectionView:(ASCollectionView*) collectionView;
- (void) invalidate;
- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect;

- (NSInteger) numberOfSections;
- (NSInteger) numberOfItemsInSection:(NSInteger)section;
- (NSInteger) numberOfItems;
- (CGSize) collectionViewContentSize;



@end
