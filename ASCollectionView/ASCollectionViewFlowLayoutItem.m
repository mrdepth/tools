//
//  ASCollectionViewFlowLayoutItem.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewFlowLayoutItem.h"

@implementation ASCollectionViewFlowLayoutItem

- (id) copyWithZone:(NSZone *)zone {
	ASCollectionViewFlowLayoutItem* item = [[self.class alloc] init];
	item.frame = _frame;
	return item;
}

@end
