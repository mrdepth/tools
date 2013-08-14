//
//  ASCollectionViewFlowLayoutData.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewFlowLayoutData.h"
#import "ASCollectionViewLayoutAttributes.h"
#import "ASCollectionViewFlowLayout.h"

@interface ASCollectionViewFlowLayoutData()
@property (nonatomic, strong, readwrite) NSMutableArray* sections;
@property (nonatomic, assign, readwrite) CGSize contentSize;

@end

@implementation ASCollectionViewFlowLayoutData

- (id) init {
	if (self = [super init]) {
		_sections = [NSMutableArray new];
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone {
	ASCollectionViewFlowLayoutData* data = [[self.class alloc] init];
	data.flowLayout = _flowLayout;
	data.sections = [[NSMutableArray alloc] initWithArray:_sections copyItems:YES];
	data.dimension = _dimension;
	data.contentSize = _contentSize;
	return data;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray* layoutAttributesArray = [NSMutableArray new];
	
	NSInteger sectionIndex = 0;
	for (ASCollectionViewFlowLayoutSection* section in _sections) {
		if (section.headerDimension > 0 && CGRectIntersectsRect(section.headerFrame, rect)) {
			ASCollectionViewLayoutAttributes* layoutAttributes = [self.flowLayout layoutAttributesForSupplementaryViewOfKind:ASCollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:sectionIndex]];
			if (layoutAttributes)
				[layoutAttributesArray addObject:layoutAttributes];
		}
		if (section.footerDimension > 0 && CGRectIntersectsRect(section.footerFrame, rect)) {
			ASCollectionViewLayoutAttributes* layoutAttributes = [self.flowLayout layoutAttributesForSupplementaryViewOfKind:ASCollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:sectionIndex]];
			if (layoutAttributes)
				[layoutAttributesArray addObject:layoutAttributes];
		}
		if (section.splitIndexPath && CGRectIntersectsRect(section.splitFrame, rect)) {
			ASCollectionViewLayoutAttributes* layoutAttributes = [self.flowLayout layoutAttributesForSupplementaryViewOfKind:ASCollectionElementKindSectionSplit atIndexPath:section.splitIndexPath];
			if (layoutAttributes)
				[layoutAttributesArray addObject:layoutAttributes];
		}

		
		if (CGRectIntersectsRect(section.frame, rect)) {
			NSInteger itemIndex = 0;
			
			for (ASCollectionViewFlowLayoutRow* row in section.rows) {
				if (CGRectIntersectsRect(row.frame, rect)) {
					for (ASCollectionViewFlowLayoutItem* item in row.items) {
						if (item != section.placeholderItem) {
							ASCollectionViewLayoutAttributes* layoutAttributes = [[_flowLayout.class layoutAttributesClass] new];
							layoutAttributes.frame = item.frame;
							layoutAttributes.alpha = 1.0;
							layoutAttributes.indexPath = item.indexPath;
							[layoutAttributesArray addObject:layoutAttributes];
						}
					}
				}
				else
					itemIndex += row.items.count;
			}
		}
		sectionIndex++;
	}
	return layoutAttributesArray;
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	ASCollectionViewFlowLayoutSection* section = _sections[indexPath.section];
	ASCollectionViewFlowLayoutItem* item = section.items[indexPath.item];
	ASCollectionViewLayoutAttributes* layoutAttributes = [[_flowLayout.class layoutAttributesClass] new];
	layoutAttributes.frame = item.frame;
	layoutAttributes.alpha = 1.0;
	layoutAttributes.indexPath = indexPath;
	return layoutAttributes;
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	ASCollectionViewFlowLayoutSection* section = _sections[indexPath.section];
	ASCollectionViewLayoutAttributes* layoutAttributes = nil;

	if ([kind isEqualToString:ASCollectionElementKindSectionHeader] && section.headerDimension > 0) {
		layoutAttributes = [[_flowLayout.class layoutAttributesClass] new];
		layoutAttributes.frame = section.headerFrame;
		layoutAttributes.alpha = 1.0;
		layoutAttributes.representedElementKind = ASCollectionElementKindSectionHeader;
		layoutAttributes.representedElementCategory = ASCollectionElementCategorySupplementaryView;
		layoutAttributes.indexPath = indexPath;
	}
	else if ([kind isEqualToString:ASCollectionElementKindSectionFooter] && section.footerDimension > 0) {
		layoutAttributes = [[_flowLayout.class layoutAttributesClass] new];
		layoutAttributes.frame = section.footerFrame;
		layoutAttributes.alpha = 1.0;
		layoutAttributes.representedElementKind = ASCollectionElementKindSectionFooter;
		layoutAttributes.representedElementCategory = ASCollectionElementCategorySupplementaryView;
		layoutAttributes.indexPath = indexPath;
	}
	else if ([kind isEqualToString:ASCollectionElementKindSectionSplit] && section.splitIndexPath && [section.splitIndexPath isEqual:indexPath]) {
		layoutAttributes = [[_flowLayout.class layoutAttributesClass] new];
		layoutAttributes.frame = section.splitFrame;
		layoutAttributes.alpha = 1.0;
		layoutAttributes.representedElementKind = ASCollectionElementKindSectionSplit;
		layoutAttributes.representedElementCategory = ASCollectionElementCategorySupplementaryView;
		layoutAttributes.indexPath = indexPath;
	}

	return layoutAttributes;
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForPlaceholderInSection:(NSInteger) section {
	return [self.sections[section] placeholderItem];
}

- (void) addSection:(ASCollectionViewFlowLayoutSection*) section {
	[_sections addObject:section];
}

- (void) layout {
	CGRect contentRect = CGRectMake(0, 0, _dimension, 0);
	for (ASCollectionViewFlowLayoutSection* section in _sections) {
		UIEdgeInsets margins = section.margins;
		CGRect frame = CGRectZero;
		frame.origin.x += margins.left;
		frame.origin.y = contentRect.size.height + margins.top;
		frame.size.width = _dimension - (margins.left + margins.right);
		section.frame = frame;
		[section layout];
		frame.size.height = section.frame.size.height + section.margins.bottom;
		section.frame = frame;
		contentRect = CGRectUnion(contentRect, frame);
	}
	_contentSize = contentRect.size;
}

@end
