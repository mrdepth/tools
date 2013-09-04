//
//  ASCollectionView.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionView.h"
#import "ASCollectionViewData.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSIndexPath (ASCollectionView)

+ (NSIndexPath *)indexPathForItem:(NSInteger)item inSection:(NSInteger)section {
	return [NSIndexPath indexPathForRow:item inSection:section];
}

- (NSInteger)item {
	return self.row;
}

@end


@interface ASCollectionViewLayout()
@property (nonatomic, weak, readwrite) ASCollectionView *collectionView;
@end

@interface ASCollectionReusableView()
@property (nonatomic, strong) ASCollectionViewLayoutAttributes* layoutAttributes;
@end

@interface ASCollectionView()<UIScrollViewDelegate> {
	struct {
		unsigned int updating: 1;
		unsigned int updatingLayout:1;
		unsigned int contentSizeChanging:1;
	} _flags;
}

@property (nonatomic, strong) NSMutableDictionary* visibleViews;
@property (nonatomic, strong) NSMutableArray* indexPathsForHighlightedItems;
@property (nonatomic, strong) NSMutableArray* indexPathsForSelectedItems;
@property (nonatomic, strong) NSMutableDictionary* cellsReuseQueue;
@property (nonatomic, strong) NSMutableDictionary* supplementaryReuseQueue;
@property (nonatomic, strong) NSMutableDictionary* decorationReuseQueue;

@property (nonatomic, strong) NSMutableArray *insertItems;
@property (nonatomic, strong) NSMutableArray *deleteItems;
@property (nonatomic, strong) NSMutableArray *reloadItems;
@property (nonatomic, strong) NSMutableArray *moveItems;

@property (nonatomic, strong) NSMutableDictionary* indexesOldToNewMap;
@property (nonatomic, strong) NSMutableDictionary* indexesNewToOldMap;


@property (nonatomic, strong) ASCollectionViewData* collectionViewData;

- (void) setup;
- (void) updateVisibleCells;
- (ASCollectionViewCell *)createPreparedCellForItemAtIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(ASCollectionViewLayoutAttributes *)layoutAttributes;
- (ASCollectionReusableView *)createPreparedSupplementaryViewForElementOfKind:(NSString *)kind
																  atIndexPath:(NSIndexPath *)indexPath
														 withLayoutAttributes:(ASCollectionViewLayoutAttributes *)layoutAttributes;
- (ASCollectionReusableView *)createPreparedDecorationViewForElementOfKind:(NSString *)kind
															   atIndexPath:(NSIndexPath *)indexPath
													  withLayoutAttributes:(ASCollectionViewLayoutAttributes *)layoutAttributes;
- (void) reuseView:(ASCollectionReusableView*) view;
- (void)setupCellAnimations;
- (void)endItemAnimations;
- (void)updateRowsAtIndexPaths:(NSArray *)indexPaths updateAction:(ASCollectionUpdateAction)updateAction;
- (void)updateSections:(NSIndexSet *)sections updateAction:(ASCollectionUpdateAction)updateAction;

- (NSMutableArray *)arrayForUpdateAction:(ASCollectionUpdateAction) updateAction;
- (void) onCellTap:(UITapGestureRecognizer*) recognizer;
@end

@implementation ASCollectionView
@synthesize delegate = delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	if (!self.collectionViewData) {
		[self setup];
		self.collectionViewData = [[ASCollectionViewData alloc] initWithCollectionView:self];
		[self.collectionViewLayout prepareLayout];
	}
	
	if (!_flags.updating) {
		[self updateVisibleCells];
		CGSize contentSize = [self.collectionViewData collectionViewContentSize];
		if (!_flags.contentSizeChanging && !CGSizeEqualToSize(contentSize, self.contentSize)) {
			CGFloat y0 = self.contentOffset.y;
			CGFloat y1 = MAX(contentSize.height - self.frame.size.height, 0);
			if (y1 < y0) {
				_flags.contentSizeChanging = YES;
				[self setContentOffset:CGPointMake(0, y1) animated:YES];
			}
			else
				self.contentSize = contentSize;
		}
	}
}

- (void) setFrame:(CGRect)frame {
	CGRect oldFrame = self.frame;
	[super setFrame:frame];
	if (oldFrame.size.width != frame.size.width) {
		[self.collectionViewData invalidate];
		[self setNeedsLayout];
//		[self performBatchUpdates:nil completion:nil];
	}
	else if (oldFrame.size.height != frame.size.height) {
		[self.collectionViewData invalidate];
		[self setNeedsLayout];
	}
}

- (void) addSubview:(UIView *)view {
	if ([view isKindOfClass:[ASCollectionReusableView class]]) {
		NSInteger insertionIndex = MAX((NSInteger)(self.subviews.count - (self.dragging ? 1 : 0)), 0);
		[self insertSubview:view atIndex:insertionIndex];
		
		NSMutableArray *floatingViews = [[NSMutableArray alloc] init];
		for (UIView *uiView in self.subviews) {
			if ([uiView isKindOfClass:ASCollectionReusableView.class] && [[(ASCollectionReusableView *)uiView layoutAttributes] zIndex] > 0) {
				[floatingViews addObject:uiView];
			}
		}
		[floatingViews sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"layoutAttributes.zIndex" ascending:YES]]];
		for (UIView* uiView in floatingViews)
			[self bringSubviewToFront:uiView];
	}
	else {
		[super addSubview:view];
	}
}

- (void) setEditing:(BOOL)editing {
	[self setEditing:editing animated:NO];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
	_editing = editing;
	if (animated) {
		[UIView animateWithDuration:ASCollectionViewAnimationDuration
							  delay:0
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 for (ASCollectionViewCell* cell in [self visibleCells])
								 [cell setEditing:editing animated:YES];
						 } completion:nil];
	}
	else
		for (ASCollectionViewCell* cell in [self visibleCells])
			[cell setEditing:editing animated:NO];
}


- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath {
	NSMutableArray* array = self.cellsReuseQueue[identifier];
	if (array) {
		id view = [array lastObject];
		[array removeLastObject];
		return view;
	}
	else
		return nil;
}

- (id)dequeueReusableSupplementaryViewOfKind:(NSString*)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath {
	NSMutableArray* array = self.supplementaryReuseQueue[identifier];
	if (array) {
		id view = [array lastObject];
		[array removeLastObject];
		return view;
	}
	else
		return nil;
}

- (id)dequeueReusableDecorationViewOfKind:(NSString*)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath {
	NSMutableArray* array = self.decorationReuseQueue[identifier];
	if (array) {
		id view = [array lastObject];
		[array removeLastObject];
		return view;
	}
	else
		return nil;
}

- (NSArray *)indexPathsForSelectedItems {
	return [_indexPathsForSelectedItems copy];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition {
	if (![_indexPathsForSelectedItems containsObject:indexPath]) {
		[_indexPathsForSelectedItems addObject:indexPath];
		ASCollectionViewCell* cell = [self cellForItemAtIndexPath:indexPath];
		
		if (animated) {
			[UIView animateWithDuration:ASCollectionViewSelectionAnimationDuration
								  delay:0
								options:UIViewAnimationOptionBeginFromCurrentState
							 animations:^{
								 [cell setSelected:YES animated:YES];
							 } completion:nil];
		}
		else
			[cell setSelected:YES animated:NO];
	}
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	if ([_indexPathsForSelectedItems containsObject:indexPath]) {
		[_indexPathsForSelectedItems removeObject:indexPath];
		ASCollectionViewCell* cell = [self cellForItemAtIndexPath:indexPath];
		if (animated) {
			[UIView animateWithDuration:ASCollectionViewSelectionAnimationDuration
								  delay:0
								options:UIViewAnimationOptionBeginFromCurrentState
							 animations:^{
								 [cell setSelected:NO animated:YES];
							 } completion:nil];
		}
		else
			[cell setSelected:NO animated:NO];
	}
}

- (void)reloadData {
	[self.collectionViewData invalidate];
	[self setNeedsLayout];
	[_visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, ASCollectionReusableView* view, BOOL *stop) {
		[view removeFromSuperview];
	}];
	[_visibleViews removeAllObjects];
	[_indexPathsForHighlightedItems removeAllObjects];
	[_indexPathsForSelectedItems removeAllObjects];
	[_supplementaryReuseQueue removeAllObjects];
	[_decorationReuseQueue removeAllObjects];
	[_visibleViews removeAllObjects];
	[_visibleViews removeAllObjects];
}

- (NSInteger)numberOfSections {
	return [self.collectionViewData numberOfSections];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	return [self.collectionViewData numberOfItemsInSection:section];
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return [self.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point {
	__block NSIndexPath* indexPath = nil;
	[_visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, ASCollectionReusableView* view, BOOL *stop) {
		if (view.layoutAttributes.representedElementCategory == ASCollectionElementCategoryCell && CGRectContainsPoint(view.frame, point)) {
			indexPath = [self indexPathForCell:(ASCollectionViewCell*) view];
			*stop = YES;
		}
	}];
	return indexPath;
}

- (NSIndexPath *)indexPathForCell:(ASCollectionViewCell *)cell {
	return cell.layoutAttributes.indexPath;
}

- (ASCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	id key = [ASCollectionViewLayoutAttributes keyForItemAtIndexPath:indexPath];
	return _visibleViews[key];
}

- (NSArray *)visibleCells {
	NSMutableArray* visibleCells = [NSMutableArray new];
	[_visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, ASCollectionReusableView* view, BOOL *stop) {
		if ([view isKindOfClass:[ASCollectionViewCell class]])
			[visibleCells addObject:view];
	}];
	return visibleCells;
}

- (NSArray *)indexPathsForVisibleItems {
	NSMutableArray* indexPaths = [NSMutableArray new];
	for (ASCollectionViewCell* cell in [self visibleCells])
		[indexPaths addObject:[self indexPathForCell:cell]];
	return indexPaths;
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated {
	
}

- (void)insertSections:(NSIndexSet *)sections {
	[self updateSections:sections updateAction:ASCollectionUpdateActionInsert];
}

- (void)deleteSections:(NSIndexSet *)sections {
	[self updateSections:sections updateAction:ASCollectionUpdateActionDelete];
}

- (void)reloadSections:(NSIndexSet *)sections {
	[self updateSections:sections updateAction:ASCollectionUpdateActionReload];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
	if (!self.collectionViewData)
		return;

    BOOL updating = _flags.updating;
    if (!updating)
		[self setupCellAnimations];
	
    NSMutableArray *array = [self arrayForUpdateAction:ASCollectionUpdateActionMove];
	NSIndexPath* indexPath = [NSIndexPath indexPathForItem:NSNotFound inSection:section];
	NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:NSNotFound inSection:newSection];
	ASCollectionViewUpdateItem *updateItem = [[ASCollectionViewUpdateItem alloc] initWithInitialIndexPath:indexPath finalIndexPath:newIndexPath updateAction:ASCollectionUpdateActionMove];
	[array addObject:updateItem];
    if (!updating)
		[self endItemAnimations];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths {
	[self updateRowsAtIndexPaths:indexPaths updateAction:ASCollectionUpdateActionInsert];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths {
	[self updateRowsAtIndexPaths:indexPaths updateAction:ASCollectionUpdateActionDelete];
}

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths {
	[self updateRowsAtIndexPaths:indexPaths updateAction:ASCollectionUpdateActionReload];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
	if (!self.collectionViewData)
		return;

    BOOL updating = _flags.updating;
    if (!updating)
		[self setupCellAnimations];
	
    NSMutableArray *array = [self arrayForUpdateAction:ASCollectionUpdateActionMove];
	ASCollectionViewUpdateItem *updateItem = [[ASCollectionViewUpdateItem alloc] initWithInitialIndexPath:indexPath finalIndexPath:newIndexPath updateAction:ASCollectionUpdateActionMove];
	[array addObject:updateItem];
    if (!updating)
		[self endItemAnimations];
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion {
	[self setupCellAnimations];
	if (updates)
		updates();
	[self endItemAnimations];
	if (completion)
		completion(YES);
}

#pragma mark - Accessors

- (void) setCollectionViewLayout:(ASCollectionViewLayout *)collectionViewLayout {
	_collectionViewLayout = collectionViewLayout;
	_collectionViewLayout.collectionView = self;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if (_flags.contentSizeChanging) {
		self.contentSize = self.collectionViewData.collectionViewContentSize;
		_flags.contentSizeChanging = NO;
	}
	if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
		[self.delegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (BOOL) respondsToSelector:(SEL)aSelector {
	return [self.class instancesRespondToSelector:aSelector] ||	[self.delegate respondsToSelector:aSelector];
}

- (id) forwardingTargetForSelector:(SEL)aSelector {
	if ([self.class instancesRespondToSelector:aSelector])
		return self;
	else if ([self.delegate respondsToSelector:aSelector])
		return delegate;
	else
		return nil;
}


#pragma mark - Private

- (void) setup {
	[super setDelegate:self];
	self.visibleViews = [NSMutableDictionary new];
	self.indexPathsForHighlightedItems = [NSMutableArray new];
	self.indexPathsForSelectedItems = [NSMutableArray new];
	self.cellsReuseQueue = [NSMutableDictionary new];
	self.supplementaryReuseQueue = [NSMutableDictionary new];
	self.decorationReuseQueue = [NSMutableDictionary new];
}

- (void)updateVisibleCells {
	NSArray* visible = [self.collectionViewData layoutAttributesForElementsInRect:self.bounds];
	
	NSMutableSet* visibleKeys = [[NSMutableSet alloc] init];
	NSMutableSet* invisibleKeys = [[NSMutableSet alloc] initWithArray:_visibleViews.allKeys];
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	for (ASCollectionViewLayoutAttributes* layoutAttributes in visible) {
		[visibleKeys addObject:layoutAttributes.key];
		ASCollectionReusableView* view = _visibleViews[layoutAttributes.key];
		if (view) {
			[view applyLayoutAttributes:layoutAttributes];
		}
		else {
			if (layoutAttributes.representedElementCategory == ASCollectionElementCategoryCell)
				view = [self createPreparedCellForItemAtIndexPath:layoutAttributes.indexPath withLayoutAttributes:layoutAttributes];
			else if (layoutAttributes.representedElementCategory == ASCollectionElementCategorySupplementaryView)
				view = [self createPreparedSupplementaryViewForElementOfKind:layoutAttributes.representedElementKind atIndexPath:layoutAttributes.indexPath withLayoutAttributes:layoutAttributes];
			else if (layoutAttributes.representedElementCategory == ASCollectionElementCategoryDecorationView)
				view = [self createPreparedDecorationViewForElementOfKind:layoutAttributes.representedElementKind atIndexPath:layoutAttributes.indexPath withLayoutAttributes:layoutAttributes];
			
			NSAssert(view, @"View cannot be nil");
			[self addSubview:view];
			[view.layer removeAllAnimations];
			_visibleViews[layoutAttributes.key] = view;
		}
	}
	[CATransaction flush];
	[CATransaction commit];
	
	[invisibleKeys minusSet:visibleKeys];
	for (id key in invisibleKeys) {
		ASCollectionReusableView* view = _visibleViews[key];
		if (view.layer.animationKeys.count == 0) {
			[self reuseView:view];
			[_visibleViews removeObjectForKey:key];
		}
	}
}

- (ASCollectionViewCell *)createPreparedCellForItemAtIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(ASCollectionViewLayoutAttributes *)layoutAttributes {
    ASCollectionViewCell *cell;
	if ([self.collectionViewLayout respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)])
		cell = [(id<ASCollectionViewDataSource>) self.collectionViewLayout collectionView:self cellForItemAtIndexPath:indexPath];
	else
		cell = [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
	
	cell.collectionView = self;
	cell.editing = self.editing;
	UIGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCellTap:)];
	[cell addGestureRecognizer:recognizer];
    [cell applyLayoutAttributes:layoutAttributes];

    [cell setHighlighted:[_indexPathsForHighlightedItems containsObject:indexPath]];
    [cell setSelected:[_indexPathsForSelectedItems containsObject:indexPath]];
	
    return cell;
}

- (ASCollectionReusableView *)createPreparedSupplementaryViewForElementOfKind:(NSString *)kind
																   atIndexPath:(NSIndexPath *)indexPath
														  withLayoutAttributes:(ASCollectionViewLayoutAttributes *)layoutAttributes {
	ASCollectionReusableView *view;
	if ([self.collectionViewLayout respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)])
		view = [(id<ASCollectionViewDataSource>) self.collectionViewLayout collectionView:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
	else
		view = [self.dataSource collectionView:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];

	
	view.collectionView = self;
	[view applyLayoutAttributes:layoutAttributes];
    return view;
}

- (ASCollectionReusableView *)createPreparedDecorationViewForElementOfKind:(NSString *)kind
																  atIndexPath:(NSIndexPath *)indexPath
														 withLayoutAttributes:(ASCollectionViewLayoutAttributes *)layoutAttributes {
	ASCollectionReusableView *view;
	if ([self.collectionViewLayout respondsToSelector:@selector(collectionView:viewForDecorationElementOfKind:atIndexPath:)])
		view = [(id<ASCollectionViewDataSource>) self.collectionViewLayout collectionView:self viewForDecorationElementOfKind:kind atIndexPath:indexPath];
	else
		view = [self.dataSource collectionView:self viewForDecorationElementOfKind:kind atIndexPath:indexPath];

	view.collectionView = self;
	[view applyLayoutAttributes:layoutAttributes];
    return view;
}


- (void) reuseView:(ASCollectionReusableView*) view {
	id key = view.layoutAttributes.key;
	if (_visibleViews[key] == view)
		[_visibleViews removeObjectForKey:key];

	if (view.layoutAttributes.representedElementCategory == ASCollectionElementCategoryCell) {
		NSMutableArray* array = self.cellsReuseQueue[view.reuseIdentifier];
		if (!array)
			self.cellsReuseQueue[view.reuseIdentifier] = array = [NSMutableArray new];
		[array addObject:view];
	}
	else if (view.layoutAttributes.representedElementCategory == ASCollectionElementCategorySupplementaryView) {
		NSMutableArray* array = self.supplementaryReuseQueue[view.reuseIdentifier];
		if (!array)
			self.supplementaryReuseQueue[view.reuseIdentifier] = array = [NSMutableArray new];
		[array addObject:view];
	}
	else if (view.layoutAttributes.representedElementCategory == ASCollectionElementCategoryDecorationView) {
		NSMutableArray* array = self.decorationReuseQueue[view.reuseIdentifier];
		if (!array)
			self.decorationReuseQueue[view.reuseIdentifier] = array = [NSMutableArray new];
		[array addObject:view];
	}
	[view removeFromSuperview];
}

#pragma mark - Update support

- (void)setupCellAnimations {
	_flags.updating = YES;
}

- (void)endItemAnimations {
	NSMutableArray* updateActions = [NSMutableArray new];
	
	if (_deleteItems)
		[updateActions addObjectsFromArray:_deleteItems];
	if (_moveItems)
		[updateActions addObjectsFromArray:_moveItems];
	if (_insertItems)
		[updateActions addObjectsFromArray:_insertItems];
	if (_reloadItems)
		[updateActions addObjectsFromArray:_reloadItems];
	
	NSInteger numberOfSections = [self.collectionViewData numberOfSections];
	NSMutableArray* sections = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
	
	for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
		NSInteger numberOfItems = [self.collectionViewData numberOfItemsInSection:sectionIndex];
		NSMutableArray* section = [[NSMutableArray alloc] initWithCapacity:numberOfItems];
		for (NSInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++)
			[section addObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
		[sections addObject:section];
	}
	
	NSMutableArray* allRemoves = [NSMutableArray new];
	[allRemoves addObjectsFromArray:_deleteItems];
	[allRemoves addObjectsFromArray:_moveItems];
	[allRemoves sortUsingSelector:@selector(compareToDelete:)];

	NSMutableArray* allInserts = [NSMutableArray new];
	[allInserts addObjectsFromArray:_insertItems];
	[allInserts addObjectsFromArray:_moveItems];
	[allInserts sortUsingSelector:@selector(compareToInsert:)];
	
	NSMutableDictionary* removedSections = [NSMutableDictionary new];
	
	for (ASCollectionViewUpdateItem* updateItem in allRemoves) {
		if ([updateItem isSectionUpdate]) {
			removedSections[@(updateItem.indexPathAfterUpdate.section)] = sections[updateItem.indexPathAfterUpdate.section];
			[sections removeObjectAtIndex:updateItem.indexPathBeforeUpdate.section];
		}
		else
			[sections[updateItem.indexPathBeforeUpdate.section] removeObjectAtIndex:updateItem.indexPathBeforeUpdate.item];
	}
	
	for (ASCollectionViewUpdateItem* updateItem in allInserts) {
		if (updateItem.updateAction == ASCollectionUpdateActionInsert) {
			if ([updateItem isSectionUpdate])
				[sections insertObject:[NSNull null] atIndex:updateItem.indexPathAfterUpdate.section];
			else
				[sections[updateItem.indexPathAfterUpdate.section] insertObject:[NSNull null] atIndex:updateItem.indexPathAfterUpdate.item];
		}
		else {
			if ([updateItem isSectionUpdate])
				[sections insertObject:removedSections[@(updateItem.indexPathBeforeUpdate.section)] atIndex:updateItem.indexPathAfterUpdate.section];
			else
				[sections[updateItem.indexPathAfterUpdate.section] insertObject:updateItem.indexPathBeforeUpdate atIndex:updateItem.indexPathAfterUpdate.item];
		}
	}
	
	_indexesOldToNewMap = [NSMutableDictionary new];
	_indexesNewToOldMap = [NSMutableDictionary new];
	
	numberOfSections = sections.count;
	
	for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
		NSArray* section = sections[sectionIndex];
		if ([section isKindOfClass:[NSArray class]]) {
			NSInteger numberOfItems = section.count;
			for (NSInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
				id object = sections[sectionIndex][itemIndex];
				if ([object isKindOfClass:[NSIndexPath class]]) {
					NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
					_indexesOldToNewMap[object] = newIndexPath;
					_indexesNewToOldMap[newIndexPath] = object;
				}
			}
		}
	}
	
	for (ASCollectionViewUpdateItem* updateItem in _reloadItems)
		updateItem.indexPathAfterUpdate = _indexesOldToNewMap[updateItem.indexPathBeforeUpdate];
	
	NSMutableArray* indexPathsForSelectedItems = [NSMutableArray new];
	for (NSIndexPath* indexPath in _indexPathsForSelectedItems) {
		NSIndexPath* newIndexPath = _indexesOldToNewMap[indexPath];
		if (newIndexPath)
			[indexPathsForSelectedItems addObject:newIndexPath];
	}
	_indexPathsForSelectedItems = indexPathsForSelectedItems;
	
	NSMutableArray* indexPathsForHighlightedItems = [NSMutableArray new];
	for (NSIndexPath* indexPath in _indexPathsForHighlightedItems) {
		NSIndexPath* newIndexPath = _indexesOldToNewMap[indexPath];
		if (newIndexPath)
			[indexPathsForHighlightedItems addObject:newIndexPath];
	}
	_indexPathsForHighlightedItems = indexPathsForHighlightedItems;

	
	[self.collectionViewLayout prepareForCollectionViewUpdates:updateActions];
	[self.collectionViewData invalidate];

	
	NSMutableArray* animations = [NSMutableArray new];
	
	NSMutableDictionary* visibleViews = [_visibleViews mutableCopy];
	[_visibleViews removeAllObjects];
	
	NSMutableDictionary* newlyVisibleLayoutAttributes = [NSMutableDictionary new];
	for (ASCollectionViewLayoutAttributes* layoutAttributes in [self.collectionViewData layoutAttributesForElementsInRect:self.bounds]) {
		newlyVisibleLayoutAttributes[layoutAttributes.key] = layoutAttributes;
	}
	NSMutableArray* toReuse = [NSMutableArray new];
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];

	
	for (ASCollectionViewUpdateItem* updateItem in updateActions) {
		if (updateItem.isSectionUpdate) {
			if (updateItem.updateAction == ASCollectionUpdateActionDelete) {
				NSInteger section = updateItem.indexPathBeforeUpdate.section;
				NSMutableArray* keysToDelete = [NSMutableArray new];
				
				[visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, ASCollectionReusableView* view, BOOL *stop) {
					if (view.layoutAttributes.indexPath.section == section) {
						ASCollectionViewLayoutAttributes* finalAttributes = [self.collectionViewLayout finalLayoutAttributesForDisappearingItemAtIndexPath:updateItem.indexPathBeforeUpdate];
						if (!finalAttributes) {
							finalAttributes = [view.layoutAttributes copy];
							finalAttributes.alpha = 0.0;
						}
						[animations addObject:@{@"view" : view, @"initialAttributes" : view.layoutAttributes, @"finalAttributes" : finalAttributes}];
						[toReuse addObject:view];
						[keysToDelete addObject:key];
					}
				}];
				
				[visibleViews removeObjectsForKeys:keysToDelete];
			}
			else if (updateItem.updateAction == ASCollectionUpdateActionInsert) {
				NSInteger section = updateItem.indexPathAfterUpdate.section;
				NSMutableArray* keysToDelete = [NSMutableArray new];

				[newlyVisibleLayoutAttributes enumerateKeysAndObjectsUsingBlock:^(id key, ASCollectionViewLayoutAttributes* finalAttributes, BOOL *stop) {
					if (finalAttributes.indexPath.section == section) {
						ASCollectionViewLayoutAttributes* initialAttributes = [self.collectionViewLayout initialLayoutAttributesForAppearingItemAtIndexPath:finalAttributes.indexPath];
						if (!initialAttributes) {
							initialAttributes = [finalAttributes copy];
							initialAttributes.alpha = 0.0;
						}
						
						ASCollectionReusableView* view = [self createPreparedCellForItemAtIndexPath:initialAttributes.indexPath withLayoutAttributes:initialAttributes];
						[self addSubview:view];
						_visibleViews[key] = view;
						[animations addObject:@{@"view" : view, @"initialAttributes" : initialAttributes, @"finalAttributes" : finalAttributes, @"ignoreCurrentState" : @(YES)}];
						

						
						[keysToDelete addObject:key];
					}
				}];
				
				[newlyVisibleLayoutAttributes removeObjectsForKeys:keysToDelete];
			}
#warning TODO: move sections
		}
		else {
			if (updateItem.updateAction == ASCollectionUpdateActionDelete) {
				id key = [ASCollectionViewLayoutAttributes keyForItemAtIndexPath:updateItem.indexPathBeforeUpdate];
				ASCollectionReusableView* view = visibleViews[key];
				if (view) {
					ASCollectionViewLayoutAttributes* finalAttributes = [self.collectionViewLayout finalLayoutAttributesForDisappearingItemAtIndexPath:updateItem.indexPathBeforeUpdate];
					if (!finalAttributes) {
						finalAttributes = [view.layoutAttributes copy];
						finalAttributes.alpha = 0.0;
					}
					[animations addObject:@{@"view" : view, @"initialAttributes" : view.layoutAttributes, @"finalAttributes" : finalAttributes}];
					[toReuse addObject:view];
					[visibleViews removeObjectForKey:key];
				}
				[_indexPathsForSelectedItems removeObject:updateItem.indexPathBeforeUpdate];
				[_indexPathsForHighlightedItems removeObject:updateItem.indexPathBeforeUpdate];
			}
			else if (updateItem.updateAction == ASCollectionUpdateActionInsert) {
				id key = [ASCollectionViewLayoutAttributes keyForItemAtIndexPath:updateItem.indexPathAfterUpdate];

				ASCollectionViewLayoutAttributes* initialAttributes = [self.collectionViewLayout initialLayoutAttributesForAppearingItemAtIndexPath:updateItem.indexPathAfterUpdate];
				ASCollectionViewLayoutAttributes* finalAttributes = newlyVisibleLayoutAttributes[key];
				ASCollectionReusableView* view = nil;
				if (finalAttributes) {
					if (!initialAttributes) {
						initialAttributes = [finalAttributes copy];
						initialAttributes.alpha = 0.0;
					}
					
					view = [self createPreparedCellForItemAtIndexPath:updateItem.indexPathAfterUpdate withLayoutAttributes:initialAttributes];
					[self addSubview:view];
					_visibleViews[key] = view;
					[animations addObject:@{@"view" : view, @"initialAttributes" : initialAttributes, @"finalAttributes" : finalAttributes, @"ignoreCurrentState" : @(YES)}];
					
					[newlyVisibleLayoutAttributes removeObjectForKey:initialAttributes.key];
				}
			}
			else if (updateItem.updateAction == ASCollectionUpdateActionReload) {
				id appearingKey = [ASCollectionViewLayoutAttributes keyForItemAtIndexPath:updateItem.indexPathAfterUpdate];
				ASCollectionViewLayoutAttributes* initialAppearingAttributes = [self.collectionViewLayout initialLayoutAttributesForAppearingItemAtIndexPath:updateItem.indexPathAfterUpdate];
				ASCollectionViewLayoutAttributes* finalAppearingAttributes = newlyVisibleLayoutAttributes[appearingKey];

				id disappearingKey = [ASCollectionViewLayoutAttributes keyForItemAtIndexPath:updateItem.indexPathBeforeUpdate];
				ASCollectionViewLayoutAttributes* initialDisappearingAttributes = nil;
				ASCollectionViewLayoutAttributes* finalDisappearingAttributes = [self.collectionViewLayout finalLayoutAttributesForDisappearingItemAtIndexPath:updateItem.indexPathBeforeUpdate];
				
				ASCollectionReusableView* view = visibleViews[disappearingKey];
				if (view) {
					initialDisappearingAttributes = view.layoutAttributes;
					if (!finalDisappearingAttributes) {
						if (finalAppearingAttributes)
							finalDisappearingAttributes = [finalAppearingAttributes copy];
						else
							finalDisappearingAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:updateItem.indexPathAfterUpdate];
						finalDisappearingAttributes.alpha = 0.0;
					}
					[animations addObject:@{@"view" : view, @"initialAttributes" : initialDisappearingAttributes, @"finalAttributes" : finalDisappearingAttributes}];
					[toReuse addObject:view];
					[visibleViews removeObjectForKey:disappearingKey];
				}
				
				if (finalAppearingAttributes) {
					ASCollectionViewLayoutAttributes* initialAttributes = [self.collectionViewLayout finalLayoutAttributesForDisappearingItemAtIndexPath:updateItem.indexPathAfterUpdate];
					if (!initialAppearingAttributes) {
						initialAppearingAttributes = [initialDisappearingAttributes copy];
						initialAppearingAttributes.alpha = 0.0;
					}
					
					view = [self createPreparedCellForItemAtIndexPath:updateItem.indexPathAfterUpdate withLayoutAttributes:initialAttributes];
					
					NSAssert(view, @"View cannot be nil");
					NSAssert(initialAppearingAttributes, @"Attributes cannot be nil");
					[self addSubview:view];
					_visibleViews[appearingKey] = view;
					[animations addObject:@{@"view" : view, @"initialAttributes" : initialAppearingAttributes, @"finalAttributes" : finalAppearingAttributes, @"ignoreCurrentState" : @(YES)}];
					
					[newlyVisibleLayoutAttributes removeObjectForKey:appearingKey];
				}
			}
		}
	}
	
	[visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, ASCollectionReusableView* view, BOOL *stop) {
		if (view.layoutAttributes.representedElementCategory == ASCollectionElementCategoryCell) {
			NSIndexPath* newIndexPath = _indexesOldToNewMap[view.layoutAttributes.indexPath];
			id newKey = [ASCollectionViewLayoutAttributes keyForItemAtIndexPath:newIndexPath];

			ASCollectionViewLayoutAttributes* finalAttributes = newlyVisibleLayoutAttributes[newKey];
			if (!finalAttributes)
				finalAttributes = [self.collectionViewLayout finalLayoutAttributesForDisappearingItemAtIndexPath:view.layoutAttributes.indexPath];
			
			if (_visibleViews[key] == view)
				[_visibleViews removeObjectForKey:key];
			view.layoutAttributes.indexPath = newIndexPath;
			_visibleViews[view.layoutAttributes.key] = view;
			
			if (!finalAttributes)
				finalAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:newIndexPath];
			if (finalAttributes) {
				if (newlyVisibleLayoutAttributes[newKey]) {
					[newlyVisibleLayoutAttributes removeObjectForKey:newKey];
					[animations addObject:@{@"view" : view, @"initialAttributes" : view.layoutAttributes, @"finalAttributes" : finalAttributes}];
				}
				else {
					[animations addObject:@{@"view" : view, @"initialAttributes" : view.layoutAttributes, @"finalAttributes" : finalAttributes}];
					[toReuse addObject:view];
				}
			}
		}
		else if (view.layoutAttributes.representedElementCategory == ASCollectionElementCategorySupplementaryView) {
			ASCollectionViewLayoutAttributes* finalAttributes = [self.collectionViewLayout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:view.layoutAttributes.representedElementKind atIndexPath:view.layoutAttributes.indexPath];
			_visibleViews[view.layoutAttributes.key] = view;
			
			if (!finalAttributes) {
				finalAttributes = [self.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:view.layoutAttributes.representedElementKind atIndexPath:view.layoutAttributes.indexPath];
				if (!finalAttributes) {
					finalAttributes = [view.layoutAttributes copy];
					finalAttributes.alpha = 0.0;
				}
			}
			if (finalAttributes) {
				id key = view.layoutAttributes.key;
				if (newlyVisibleLayoutAttributes[key]) {
					[newlyVisibleLayoutAttributes removeObjectForKey:key];
					[animations addObject:@{@"view" : view, @"initialAttributes" : view.layoutAttributes, @"finalAttributes" : finalAttributes}];
				}
				else {
					[animations addObject:@{@"view" : view, @"initialAttributes" : view.layoutAttributes, @"finalAttributes" : finalAttributes}];
					[toReuse addObject:view];
				}
			}
		}
		else if (view.layoutAttributes.representedElementCategory == ASCollectionElementCategoryDecorationView) {
			ASCollectionViewLayoutAttributes* finalAttributes = [self.collectionViewLayout finalLayoutAttributesForDisappearingDecorationElementOfKind:view.layoutAttributes.representedElementKind atIndexPath:view.layoutAttributes.indexPath];
			_visibleViews[view.layoutAttributes.key] = view;
			
			if (!finalAttributes) {
				finalAttributes = [self.collectionViewLayout layoutAttributesForDecorationViewOfKind:view.layoutAttributes.representedElementKind atIndexPath:view.layoutAttributes.indexPath];
				if (!finalAttributes) {
					finalAttributes = [view.layoutAttributes copy];
					finalAttributes.alpha = 0.0;
				}
			}
			if (finalAttributes) {
				id key = view.layoutAttributes.key;
				if (newlyVisibleLayoutAttributes[key]) {
					[newlyVisibleLayoutAttributes removeObjectForKey:key];
					[animations addObject:@{@"view" : view, @"initialAttributes" : view.layoutAttributes, @"finalAttributes" : finalAttributes}];
				}
				else {
					[animations addObject:@{@"view" : view, @"initialAttributes" : view.layoutAttributes, @"finalAttributes" : finalAttributes}];
					[toReuse addObject:view];
				}
			}
		}
	}];
	
	for (ASCollectionViewLayoutAttributes* finalAttributes in [newlyVisibleLayoutAttributes allValues]) {
		ASCollectionViewLayoutAttributes* initialAttributes = nil;
		ASCollectionReusableView* view = nil;
		
		if (finalAttributes.representedElementCategory == ASCollectionElementCategoryCell) {
			initialAttributes = [self.collectionViewLayout initialLayoutAttributesForAppearingItemAtIndexPath:finalAttributes.indexPath];
			if (!initialAttributes) {
				initialAttributes = [finalAttributes copy];
				initialAttributes.alpha = 0.0;
			}
			
			view = [self createPreparedCellForItemAtIndexPath:finalAttributes.indexPath withLayoutAttributes:initialAttributes];
		}
		else if (finalAttributes.representedElementCategory == ASCollectionElementCategorySupplementaryView) {
			initialAttributes = [self.collectionViewLayout initialLayoutAttributesForAppearingSupplementaryElementOfKind:finalAttributes.representedElementKind atIndexPath:finalAttributes.indexPath];
			if (!initialAttributes) {
				initialAttributes = [finalAttributes copy];
				initialAttributes.alpha = 0.0;
			}
			
			view = [self createPreparedSupplementaryViewForElementOfKind:finalAttributes.representedElementKind atIndexPath:finalAttributes.indexPath withLayoutAttributes:initialAttributes];
		}
		else if (finalAttributes.representedElementCategory == ASCollectionElementCategoryDecorationView) {
			initialAttributes = [self.collectionViewLayout initialLayoutAttributesForAppearingDecorationElementOfKind:finalAttributes.representedElementKind atIndexPath:finalAttributes.indexPath];
			if (!initialAttributes) {
				initialAttributes = [finalAttributes copy];
				initialAttributes.alpha = 0.0;
			}
			
			view = [self createPreparedDecorationViewForElementOfKind:finalAttributes.representedElementKind atIndexPath:finalAttributes.indexPath withLayoutAttributes:initialAttributes];
		}

		NSAssert(view, @"View cannot be nil");
		[self addSubview:view];
		_visibleViews[finalAttributes.key] = view;
		[animations addObject:@{@"view" : view, @"initialAttributes" : initialAttributes, @"finalAttributes" : finalAttributes, @"ignoreCurrentState" : @(YES)}];

	}
	
	for (NSDictionary* animation in animations) {
		ASCollectionReusableView* view = animation[@"view"];
		[view applyLayoutAttributes:animation[@"initialAttributes"]];
	}
	[CATransaction flush];
	[CATransaction commit];
	
	[UIView animateWithDuration:ASCollectionViewAnimationDuration
						  delay:0
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 [CATransaction begin];
						 [CATransaction setDisableActions:NO];
						 [CATransaction setAnimationDuration:ASCollectionViewAnimationDuration];
						 [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
						 _flags.updatingLayout = YES;
						 for (NSDictionary* animation in animations) {
							 BOOL ignoreCurrentState = [animation[@"ignoreCurrentState"] boolValue];
							 ASCollectionReusableView* view = animation[@"view"];
							 [UIView setAnimationBeginsFromCurrentState:!ignoreCurrentState];
							 [view applyLayoutAttributes:animation[@"finalAttributes"]];
						 }
						 [CATransaction commit];
					 }
					 completion:^(BOOL finished) {
						 if (finished) {
/*							 for (ASCollectionReusableView* view in toReuse) {
								 if (view.layer.animationKeys.count == 0)
//									 NSLog(@"%@", view.layer.animationKeys);
								 [self reuseView:view];
							 }*/
							 [self setNeedsLayout];
						 }
						 _flags.updatingLayout = NO;
					 }];
	
	_deleteItems = nil;
	_insertItems = nil;
	_moveItems = nil;
	_reloadItems = nil;
	_indexesNewToOldMap = nil;
	_indexesOldToNewMap = nil;
	
	_flags.updating = NO;
	[self.collectionViewLayout finalizeCollectionViewUpdates];
}

- (void)updateRowsAtIndexPaths:(NSArray *)indexPaths updateAction:(ASCollectionUpdateAction)updateAction {
	if (!self.collectionViewData)
		return;

    BOOL updating = _flags.updating;
    if (!updating)
		[self setupCellAnimations];
	
    NSMutableArray *array = [self arrayForUpdateAction:updateAction];
	
    for (NSIndexPath *indexPath in indexPaths) {
        ASCollectionViewUpdateItem *updateItem = [[ASCollectionViewUpdateItem alloc] initWithAction:updateAction forIndexPath:indexPath];
        [array addObject:updateItem];
    }
	
    if (!updating)
		[self endItemAnimations];
}

- (void)updateSections:(NSIndexSet *)sections updateAction:(ASCollectionUpdateAction)updateAction {
	if (!self.collectionViewData)
		return;
	
    BOOL updating = _flags.updating;
    if (!updating)
		[self setupCellAnimations];
	
    NSMutableArray *array = [self arrayForUpdateAction:updateAction];
	
	[sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        ASCollectionViewUpdateItem *updateItem = [[ASCollectionViewUpdateItem alloc] initWithAction:updateAction forIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:idx]];
        [array addObject:updateItem];
	}];

    if (!updating)
		[self endItemAnimations];
}

- (NSMutableArray *)arrayForUpdateAction:(ASCollectionUpdateAction) updateAction {
    NSMutableArray *updateActions = nil;
	
    switch (updateAction) {
        case ASCollectionUpdateActionInsert:
            if (!_insertItems)
				_insertItems = [NSMutableArray new];
            updateActions = _insertItems;
            break;
        case ASCollectionUpdateActionDelete:
            if (!_deleteItems)
				_deleteItems = [NSMutableArray new];
            updateActions = _deleteItems;
            break;
        case ASCollectionUpdateActionMove:
            if (!_moveItems)
				_moveItems = [NSMutableArray new];
            updateActions = _moveItems;
            break;
        case ASCollectionUpdateActionReload:
            if (!_reloadItems)
				_reloadItems = [NSMutableArray new];
            updateActions = _reloadItems;
            break;
        default:
			break;
    }
    return updateActions;
}

#pragma mark - Touch Handlers

- (void) onCellTap:(UITapGestureRecognizer*) recognizer {
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		ASCollectionViewCell* cell = (ASCollectionViewCell*) recognizer.view;
		NSIndexPath* indexPath = [self indexPathForCell:cell];
		if (cell.selected) {
			if ([self.delegate respondsToSelector:@selector(collectionView:shouldDeselectItemAtIndexPath:)] && ![self.delegate collectionView:self shouldDeselectItemAtIndexPath:indexPath])
				return;
		}
		else {
			if ([self.delegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)] && ![self.delegate collectionView:self shouldSelectItemAtIndexPath:indexPath])
				return;
		}
		
		BOOL selected = ![_indexPathsForSelectedItems containsObject:indexPath];
		
		[UIView animateWithDuration:ASCollectionViewSelectionAnimationDuration
							  delay:0
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 if (selected) {
								 [cell setSelected:YES animated:YES];
								 [_indexPathsForSelectedItems addObject:indexPath];
							 }
							 else {
								 [cell setSelected:NO animated:YES];
								 [_indexPathsForSelectedItems removeObject:indexPath];
							 }
						 } completion:nil];
		if (selected) {
			if ([self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)])
				[self.delegate collectionView:self didSelectItemAtIndexPath:indexPath];
		}
		else {
			if ([self.delegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)])
				[self.delegate collectionView:self didDeselectItemAtIndexPath:indexPath];
		}
	}
}

@end
