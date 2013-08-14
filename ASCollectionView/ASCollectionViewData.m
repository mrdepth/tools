//
//  ASCollectionViewData.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 31.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewData.h"
#import "ASCollectionView.h"

@interface ASCollectionViewData() {
	NSInteger _numberOfSections;
	NSMutableArray* _numberOfItemsInSections;
	NSMutableDictionary* _cache;
	struct {
		unsigned int validCount: 1;
	} _flags;

}
@property (nonatomic, weak, readwrite) ASCollectionView *collectionView;

- (void) updateItemsNumber;
- (NSArray*) layoutAttributesForElementsOnPage:(NSInteger) page;
@end

@implementation ASCollectionViewData

- (id) initWithCollectionView:(ASCollectionView*) collectionView {
	if (self = [super init]) {
		self.collectionView = collectionView;
	}
	return self;
}

- (void) invalidate {
	_flags.validCount = NO;
	_cache = nil;
	[self.collectionView.collectionViewLayout invalidateLayout];
}

- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect {
	if (!_cache) {
		NSInteger n = ceilf((self.collectionViewContentSize.height / self.collectionView.frame.size.height) + 1.0);
		_cache = [[NSMutableDictionary alloc] initWithCapacity:n];
	}
	
 	float page = fabs(self.collectionView.frame.size.height) < FLT_EPSILON ? 0 : rect.origin.y / self.collectionView.frame.size.height;
	int iPage = floorf(page);
	
	NSArray* cachedAttributes = nil;
	if (fabsf(page - iPage) < FLT_EPSILON)
		cachedAttributes = [self layoutAttributesForElementsOnPage:iPage];
	else {
		NSMutableArray* array = [[NSMutableArray alloc] initWithArray:[self layoutAttributesForElementsOnPage:iPage]];
		[array addObjectsFromArray:[self layoutAttributesForElementsOnPage:iPage + 1]];
		cachedAttributes = array;
	}
	
	NSMutableArray* visibleAttributes = [NSMutableArray new];
	for (ASCollectionViewLayoutAttributes* attributes in cachedAttributes) {
		if (!attributes.shouldScroll || CGRectIntersectsRect(attributes.frame, rect))
			[visibleAttributes addObject:attributes];
	}
	
	return visibleAttributes;
}

- (NSInteger) numberOfSections {
	if (!_flags.validCount)
		[self updateItemsNumber];
	return _numberOfSections;
}

- (NSInteger) numberOfItemsInSection:(NSInteger)section {
	if (!_flags.validCount)
		[self updateItemsNumber];
	return [_numberOfItemsInSections[section] integerValue];
}

- (NSInteger) numberOfItems {
	return 0;
}

- (CGSize) collectionViewContentSize {
	return [self.collectionView.collectionViewLayout collectionViewContentSize];
}

#pragma mark - Private

- (void) updateItemsNumber {
	if ([self.collectionView.collectionViewLayout respondsToSelector:@selector(numberOfSectionsInCollectionView:)])
		_numberOfSections = [(id<ASCollectionViewDataSource>) self.collectionView.collectionViewLayout numberOfSectionsInCollectionView:self.collectionView];
	else
		_numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];

	_numberOfItemsInSections = [[NSMutableArray alloc] initWithCapacity:_numberOfSections];
	
	if ([self.collectionView.collectionViewLayout respondsToSelector:@selector(collectionView:numberOfItemsInSection:)])
		for (NSInteger i = 0; i < _numberOfSections; i++)
			_numberOfItemsInSections[i] = @([(id<ASCollectionViewDataSource>) self.collectionView.collectionViewLayout collectionView:self.collectionView numberOfItemsInSection:i]);
	else
		for (NSInteger i = 0; i < _numberOfSections; i++)
			_numberOfItemsInSections[i] = @([self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:i]);
	_flags.validCount = YES;
}

- (NSArray*) layoutAttributesForElementsOnPage:(NSInteger) page {
	NSArray* cachedPage = _cache[@(page)];
	if (!cachedPage) {
		CGRect rect = (CGRect){.origin = CGPointMake(0, page * self.collectionView.frame.size.height), .size = self.collectionView.frame.size};
		cachedPage = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
		_cache[@(page)] = cachedPage;
	}
	return cachedPage;
}

@end
