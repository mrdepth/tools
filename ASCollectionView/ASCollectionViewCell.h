//
//  ASCollectionViewCell.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionReusableView.h"

@interface ASCollectionViewCell : ASCollectionReusableView
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL editing;

- (void) setSelected:(BOOL)selected animated:(BOOL)animated;
- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
- (void) setEditing:(BOOL)editing animated:(BOOL)animated;
@end
