//
//  ASCollectionViewFlowLayoutSection.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASCollectionViewFlowLayoutRow.h"

@interface ASCollectionViewFlowLayoutSection : NSObject<NSCopying>
@property (nonatomic, strong, readonly) NSMutableArray* items;
@property (nonatomic, strong, readonly) NSMutableArray* rows;
@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) CGFloat verticalInterstice;
@property (nonatomic, assign) CGFloat horizontalInterstice;
@property (nonatomic, assign) UIEdgeInsets margins;

@property (nonatomic, assign) CGRect headerFrame;
@property (nonatomic, assign) CGRect footerFrame;
@property (nonatomic, assign) CGFloat headerDimension;
@property (nonatomic, assign) CGFloat footerDimension;

@property (nonatomic, strong) NSIndexPath* splitIndexPath;
@property (nonatomic, assign) CGFloat splitDimension;
@property (nonatomic, assign) CGRect splitFrame;

@property (nonatomic, strong) ASCollectionViewFlowLayoutItem* placeholderItem;


- (void) addItem:(ASCollectionViewFlowLayoutItem*) item;
- (void) addRow:(ASCollectionViewFlowLayoutRow*) row;
- (void) layout;

@end
