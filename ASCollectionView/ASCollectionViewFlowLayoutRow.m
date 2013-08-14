//
//  ASCollectionViewFlowLayoutRow.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewFlowLayoutRow.h"
#import "ASCollectionViewFlowLayoutSection.h"

@interface ASCollectionViewFlowLayoutRow()
@property (nonatomic, strong, readwrite) NSMutableArray* items;

@end

@implementation ASCollectionViewFlowLayoutRow

- (id) init {
	if (self = [super init]) {
		_items = [NSMutableArray new];
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone {
	ASCollectionViewFlowLayoutRow* row = [[self.class alloc] init];
	row.items = [[NSMutableArray alloc] initWithArray:_items copyItems:YES];
	row.frame = _frame;
	row.lastRow = _lastRow;

	return row;
}

- (void) addItem:(ASCollectionViewFlowLayoutItem*) item {
	[_items addObject:item];
}

- (void) layout {
	
	CGFloat horizontalInterstice = _section.horizontalInterstice;
	CGFloat rowDimension = 0;
	NSInteger expectedItemsCount = _items.count;
	
	for (ASCollectionViewFlowLayoutItem* item in _items)
		rowDimension += item.frame.size.width;

	if (_lastRow) {
		ASCollectionViewFlowLayoutItem* lastItem = [_items lastObject];
		
		int n = (_frame.size.width - (rowDimension + (_items.count - 1) * horizontalInterstice)) / (lastItem.frame.size.width + horizontalInterstice);
		expectedItemsCount += n;
		rowDimension += lastItem.frame.size.width * n;
	}
	
	horizontalInterstice = (_frame.size.width - rowDimension) / (expectedItemsCount + 1);
	
	CGFloat x = _frame.origin.x + horizontalInterstice;
	CGFloat y = _frame.origin.y;
	for (ASCollectionViewFlowLayoutItem* item in self.items) {
		CGRect frame = item.frame;
		frame.origin.x = x;
		frame.origin.y = y;
		item.frame = frame;
		x += frame.size.width + horizontalInterstice;
		_frame.size.height = MAX(_frame.size.height, frame.size.height);
	}
}

@end
