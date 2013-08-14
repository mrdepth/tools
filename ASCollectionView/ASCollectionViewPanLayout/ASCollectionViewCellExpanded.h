//
//  ASCollectionViewDragCell.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 08.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewCell.h"

@protocol ASCollectionViewCellExpanded<NSObject>
@property (nonatomic, assign) BOOL expanded;
- (void) setExpanded:(BOOL)expanded animated:(BOOL) animated;
@end
