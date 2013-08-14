//
//  ASCollectionReusableView.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCollectionViewLayoutAttributes.h"

@class ASCollectionView;
@interface ASCollectionReusableView : UIView
@property (nonatomic, weak) ASCollectionView* collectionView;
@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (nonatomic, strong, readonly) ASCollectionViewLayoutAttributes* layoutAttributes;

- (id) initWithReuseIdentifier:(NSString*) reuseIdentifier;
- (void)applyLayoutAttributes:(ASCollectionViewLayoutAttributes *)layoutAttributes;

@end
