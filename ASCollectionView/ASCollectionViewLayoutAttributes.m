//
//  ASCollectionViewLayoutAttributes.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewLayoutAttributes.h"

@implementation ASCollectionViewLayoutAttributes

- (id) copyWithZone:(NSZone *)zone {
	ASCollectionViewLayoutAttributes* layoutAttributes = [[self.class alloc] init];
	layoutAttributes.frame = _frame;
	layoutAttributes.center = _center;
	layoutAttributes.size = _size;
	layoutAttributes.transform3D = _transform3D;
	layoutAttributes.alpha = _alpha;
	layoutAttributes.zIndex = _zIndex;
	layoutAttributes.hidden = _hidden;
	layoutAttributes.indexPath = _indexPath;
	
	layoutAttributes.representedElementCategory = _representedElementCategory;
	layoutAttributes.representedElementKind = _representedElementKind;
	layoutAttributes.shouldScroll = _shouldScroll;
	return layoutAttributes;
}

- (id) init {
	if (self = [super init]) {
		self.alpha = 1.0;
		self.transform3D = CATransform3DIdentity;
		self.shouldScroll = YES;
	}
	return self;
}

- (id) key {
	return [self.class keyForElementAtIndexPath:_indexPath withElementCategory:_representedElementCategory elementKind:_representedElementKind];
}

+ (id) keyForElementAtIndexPath:(NSIndexPath*) indexPath withElementCategory:(ASCollectionElementCategory) elementCategory elementKind:(NSString*) elementKind {
	NSUInteger hash = indexPath.hash;
	hash = (((hash << 2) + elementCategory) << 4) + [elementKind hash];
	return @(hash);
}

+ (id) keyForItemAtIndexPath:(NSIndexPath*) indexPath {
	return [self keyForElementAtIndexPath:indexPath withElementCategory:ASCollectionElementCategoryCell elementKind:nil];
}

- (NSString*) description {
	return [_indexPath description];
}

@end
