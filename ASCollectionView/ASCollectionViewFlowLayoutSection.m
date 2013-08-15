//
//  ASCollectionViewFlowLayoutSection.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewFlowLayoutSection.h"

@interface ASCollectionViewFlowLayoutSection()
@property (nonatomic, strong, readwrite) NSMutableArray* items;
@property (nonatomic, strong, readwrite) NSMutableArray* rows;

@end


@implementation ASCollectionViewFlowLayoutSection

- (id) init {
	if (self = [super init]) {
		_items = [NSMutableArray new];
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone {
	ASCollectionViewFlowLayoutSection* section = [[self.class alloc] init];
	section.rows = [[NSMutableArray alloc] initWithArray:_rows copyItems:YES];
	
	for (ASCollectionViewFlowLayoutRow* row in section.rows) {
		row.section = self;
		for (ASCollectionViewFlowLayoutItem* item in row.items) {
			[section addItem:item];
		}
	}
	
	section.frame = _frame;
	
	section.verticalInterstice = _verticalInterstice;
	section.horizontalInterstice = _horizontalInterstice;
	section.margins = _margins;
	
	section.headerFrame = _headerFrame;
	section.footerFrame = _footerFrame;
	section.headerDimension = _headerDimension;
	section.footerDimension = _footerDimension;
	
	return section;
}

- (void) addItem:(ASCollectionViewFlowLayoutItem*) item {
	[_items addObject:item];
}

- (void) addRow:(ASCollectionViewFlowLayoutRow*) row {
	[_rows addObject:row];
}

- (void) layout {
	_rows = [NSMutableArray new];
	_frame.size.height = _headerDimension;
	if (_headerDimension > 0)
		_headerFrame = CGRectMake(_frame.origin.x, _frame.origin.y, _frame.size.width, _headerDimension);

	ASCollectionViewFlowLayoutRow* row = nil;
	CGFloat dimension;
	NSInteger rowIndex = 0;
	NSInteger itemRowIndex;
	
	int n = _items.count;
	
	BOOL hasSplit = NO;
	
	ASCollectionViewFlowLayoutItem* placeholderItem = self.placeholderItem;
	
	for (int i = 0; i < n;) {
		ASCollectionViewFlowLayoutItem* item = _items[i];
		if (placeholderItem && item.indexPath.item == placeholderItem.indexPath.item) {
			item = placeholderItem;
		}
		else if (CGSizeEqualToSize(item.frame.size , CGSizeZero)) {
				i++;
				continue;
			}
		
		if (!row) {
			if (rowIndex > 0)
				_frame.size.height += _verticalInterstice;

			row = [ASCollectionViewFlowLayoutRow new];
			row.section = self;
			dimension = _frame.size.width;
			itemRowIndex = 0;
			row.frame = CGRectMake(_frame.origin.x, CGRectGetMaxY(_frame), _frame.size.width, 0);
		}
		
		if (itemRowIndex > 0)
			dimension -= _horizontalInterstice;
		dimension -= item.frame.size.width;
		if (dimension >= 0 || itemRowIndex == 0) {
			if (self.splitIndexPath && [self.splitIndexPath isEqual:item.indexPath])
				hasSplit = YES;

			[row addItem:item];
			if (item != placeholderItem)
				i++;
			else
				placeholderItem = nil;
		}
		else {
			[self addRow:row];
			[row layout];
			
			_frame = CGRectUnion(_frame, row.frame);
			if (hasSplit) {
				_splitFrame = CGRectMake(_frame.origin.x, CGRectGetMaxY(_frame), _frame.size.width, _splitDimension);
				_frame = CGRectUnion(_frame, _splitFrame);
				hasSplit = NO;
			}
			
			rowIndex++;
			row = nil;
		}
		itemRowIndex++;
	}
	if (row) {
		row.lastRow = YES;
		[self addRow:row];
		[row layout];
		
		_frame = CGRectUnion(_frame, row.frame);
		
		if (hasSplit) {
			_splitFrame = CGRectMake(_frame.origin.x, CGRectGetMaxY(_frame), _frame.size.width, _splitDimension);
			_frame = CGRectUnion(_frame, _splitFrame);
			hasSplit = NO;
		}

	}
	
	if (placeholderItem) {
		if (rowIndex > 0)
			_frame.size.height += _verticalInterstice;
		
		row = [ASCollectionViewFlowLayoutRow new];
		row.section = self;
		dimension = _frame.size.width;
		itemRowIndex = 0;
		row.frame = CGRectMake(_frame.origin.x, CGRectGetMaxY(_frame), _frame.size.width, 0);
		[row addItem:placeholderItem];

		row.lastRow = YES;
		[self addRow:row];
		[row layout];
		
		_frame = CGRectUnion(_frame, row.frame);
		
		if (hasSplit) {
			_splitFrame = CGRectMake(_frame.origin.x, CGRectGetMaxY(_frame), _frame.size.width, _splitDimension);
			_frame = CGRectUnion(_frame, _splitFrame);
			hasSplit = NO;
		}
	}
	
	if (_footerDimension > 0)
		_footerFrame = CGRectMake(_frame.origin.x, CGRectGetMaxY(_frame), _frame.size.width, _footerDimension);
	_frame.size.height += _footerDimension;
}

@end
