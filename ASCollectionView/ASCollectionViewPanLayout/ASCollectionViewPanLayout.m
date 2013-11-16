//
//  ASCollectionViewPanLayout.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 06.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewPanLayout.h"
#import "ASLongPressPanGestureRecognizer.h"
#import "ASCollectionViewData.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "ASCollectionViewCellExpanded.h"

@interface ASCollectionViewLayout()
@property (nonatomic, weak, readwrite) ASCollectionView *collectionView;
@end

@interface ASCollectionView()
@property (nonatomic, strong) NSMutableDictionary* visibleViews;
@property (nonatomic, strong) ASCollectionViewData* collectionViewData;
@property (nonatomic, strong) NSMutableDictionary* indexesOldToNewMap;
@property (nonatomic, strong) NSMutableDictionary* indexesNewToOldMap;

@end

@interface ASCollectionViewCell(ASCollectionViewPanLayout)
@property (nonatomic, strong) ASLongPressPanGestureRecognizer* longPressPanGestureRecognizer;
@end

@implementation ASCollectionViewCell(ASCollectionViewPanLayout)

- (ASLongPressPanGestureRecognizer*) longPressPanGestureRecognizer {
	return objc_getAssociatedObject(self, @"longPressPanGestureRecognizer");
}

- (void) setLongPressPanGestureRecognizer:(ASLongPressPanGestureRecognizer *)longPressPanGestureRecognizer {
	objc_setAssociatedObject(self, @"longPressPanGestureRecognizer", longPressPanGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@interface ASCollectionViewPanLayout()
@property (nonatomic, weak, readwrite) ASCollectionView *collectionView;
@property (nonatomic, strong) ASCollectionViewCell* panCell;
@property (nonatomic, strong) NSMutableDictionary* finalLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary* initialLayoutAttributes;
@property (nonatomic, strong) NSMutableArray* panIndexPaths;
@property (nonatomic, strong) NSIndexPath* placeholderIndexPath;

@property (nonatomic, strong) NSMutableArray* placeholderAvailableIndexPaths;
@property (nonatomic, strong) NSMutableArray* placeholderUnavailableIndexPaths;
@property (nonatomic, strong) NSMutableArray* putAvailableIndexPaths;
@property (nonatomic, strong) NSMutableArray* putUnavailableIndexPaths;

@property (nonatomic, strong) NSIndexPath* expandedIndexPath;

@property (nonatomic, strong) CADisplayLink* displayLink;
@property (nonatomic, assign) CFTimeInterval lastTimestamp;
@property (nonatomic, assign) CGFloat autoscrollSpeed;

- (void) onLongPress:(ASLongPressPanGestureRecognizer*) recognizer;
- (void) beginPanWithCell:(ASCollectionViewCell*) cell;
- (void) endPan;
- (void) onPan;
- (void) onDisplayLink:(CADisplayLink*) displayLink;
- (BOOL) canMoveItemsToIndexPath:(NSIndexPath*) indexPath;
- (BOOL) canPutItemsToIndexPath:(NSIndexPath*) indexPath;
@end


@implementation ASCollectionViewPanLayout

- (id) init {
	if (self = [super init]) {
		self.allowsMultiplePan = YES;
	}
	return self;
}

- (UIView*) panViewContainer {
	return self.collectionView.superview;
}


/*- (void) setCollectionView:(ASCollectionView *)collectionView {
	[super setCollectionView:collectionView];
	self.collectionViewDataSource = collectionView.dataSource;
	self.collectionViewDelegate = (id<ASCollectionViewDelegatePanLayout>) collectionView.delegate;
	collectionView.delegate = self;
	collectionView.dataSource = self;
}*/

- (void) invalidateLayout {
	[super invalidateLayout];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSArray* layoutAttributes = [super layoutAttributesForElementsInRect:rect];
	if (self.expandedIndexPath) {
		for (ASCollectionViewLayoutAttributes* attributes in layoutAttributes) {
			if ([attributes.indexPath isEqual:self.expandedIndexPath]) {
				attributes.transform3D = CATransform3DMakeScale(1.2, 1.2, 1.0);
				attributes.zIndex = 1.0;
				break;
			}
		}
	}
	return layoutAttributes;
}

- (ASCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	ASCollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
	if (self.expandedIndexPath && [indexPath isEqual:self.expandedIndexPath]) {
		attributes.transform3D = CATransform3DMakeScale(1.2, 1.2, 1.0);
		attributes.zIndex = 1.0;
	}
	return attributes;
}

- (ASCollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	ASCollectionViewLayoutAttributes* layoutAttributes = self.finalLayoutAttributes[itemIndexPath];
	if (layoutAttributes)
		return layoutAttributes;
	else
		return [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
}

- (ASCollectionViewLayoutAttributes*) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	ASCollectionViewLayoutAttributes* layoutAttributes = self.initialLayoutAttributes[itemIndexPath];
	if (layoutAttributes)
		return layoutAttributes;
	else
		return [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
	if (self.panIndexPaths) {
		NSMutableArray* panIndexPaths = [NSMutableArray new];
		for (NSIndexPath* indexPath in self.panIndexPaths)
			[panIndexPaths addObject:self.collectionView.indexesOldToNewMap[indexPath]];
		self.panIndexPaths = panIndexPaths;
	}
	if (self.expandedIndexPath)
		self.expandedIndexPath = self.collectionView.indexesOldToNewMap[self.expandedIndexPath];

	if (self.placeholderAvailableIndexPaths) {
		self.placeholderAvailableIndexPaths = [NSMutableArray new];
		self.placeholderUnavailableIndexPaths = [NSMutableArray new];
		self.putAvailableIndexPaths = [NSMutableArray new];
		self.putUnavailableIndexPaths = [NSMutableArray new];
	}
	if (self.panCell)
		self.panCell.layoutAttributes.indexPath = self.collectionView.indexesOldToNewMap[self.panCell.layoutAttributes.indexPath];
	[super prepareForCollectionViewUpdates:updateItems];
}

#pragma mark - ASCollectionViewDataSource

- (ASCollectionViewCell *)collectionView:(ASCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ASCollectionViewCell* cell = [self.collectionView.dataSource collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	if (!cell.longPressPanGestureRecognizer) {
		cell.longPressPanGestureRecognizer = [[ASLongPressPanGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
		cell.longPressPanGestureRecognizer.minimumPressDuration = 0.25;
		[cell addGestureRecognizer:cell.longPressPanGestureRecognizer];
	}
	return cell;
}

#pragma mark - ASCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.panIndexPaths containsObject:indexPath])
		return CGSizeZero;
	else {
		//id<ASCollectionViewDelegateFlowLayout> delegate = (id<ASCollectionViewDelegateFlowLayout>) self.collectionView.delegate;
		//return [delegate collectionView:collectionView layout:self sizeForItemAtIndexPath:indexPath];
		return [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
	}
}

- (CGSize)collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceSizeForPlaceholderInSection:(NSInteger)section {
	return self.panCell.layoutAttributes.frame.size;
}

- (NSIndexPath*) collectionView:(ASCollectionView *)collectionView layout:(ASCollectionViewLayout*)collectionViewLayout referenceIndexPathForPlaceholderInSection:(NSInteger)section {
	return self.placeholderIndexPath && self.placeholderIndexPath.section == section ? self.placeholderIndexPath : nil;
}

#pragma mark - Private

- (void) onLongPress:(ASLongPressPanGestureRecognizer*) recognizer {
	ASCollectionViewCell* cell = (ASCollectionViewCell*) recognizer.view;
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		if (!self.panCell)
			[self beginPanWithCell:cell];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged) {
		ASCollectionViewLayoutAttributes* layoutAttributes = [cell.layoutAttributes copy];
		
		CGPoint p = [recognizer translationInView:self.collectionView.superview];
		[recognizer setTranslation:CGPointZero inView:self.collectionView.superview];
		
		CGRect frame = layoutAttributes.frame;
		frame.origin.x += p.x;
		frame.origin.y += p.y;
		layoutAttributes.frame = frame;
		
		if (self.expandedIndexPath)
			layoutAttributes.transform3D = CATransform3DMakeScale(0.8, 0.8, 1);
		else
			layoutAttributes.transform3D = CATransform3DMakeScale(1.1, 1.1, 1);

		layoutAttributes.alpha = 1.0;
		
		[cell applyLayoutAttributes:layoutAttributes];
		[self onPan];
		
		p = [recognizer locationInView:self.collectionView];
		CGFloat top = p.y - self.collectionView.contentOffset.y;
		CGFloat bottom = self.collectionView.frame.size.height - top;
		if (top < 100 && self.collectionView.contentOffset.y > 0)
			self.autoscrollSpeed = (top - 100) * 4;
		else if (bottom < 100 && self.collectionView.contentOffset.y < self.collectionView.contentSize.height - self.collectionView.bounds.size.height)
			self.autoscrollSpeed = (100 - bottom) * 4;
		else
			self.autoscrollSpeed = 0;
	}
	else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
		[self endPan];
	}
}

- (void) beginPanWithCell:(ASCollectionViewCell*) cell {
	NSIndexPath* panIndexPath = [self.collectionView indexPathForCell:cell];
	NSMutableArray* indexPaths;
	
	if (_allowsMultiplePan) {
		indexPaths = [NSMutableArray arrayWithArray:[self.collectionView indexPathsForSelectedItems]];
		if (![indexPaths containsObject:panIndexPath])
			[indexPaths addObject:panIndexPath];
	}
	else
		indexPaths = [NSMutableArray arrayWithObject:panIndexPath];
	
	
	[indexPaths sortUsingSelector:@selector(compare:)];
	
	if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:canPanItemsAtIndexPaths:)] &&
		[(id<ASCollectionViewDelegatePanLayout>) self.collectionView.delegate collectionView:self.collectionView canPanItemsAtIndexPaths:indexPaths]) {
		self.panCell = cell;

		self.placeholderAvailableIndexPaths = [NSMutableArray new];
		self.placeholderUnavailableIndexPaths = [NSMutableArray new];
		self.putAvailableIndexPaths = [NSMutableArray new];
		self.putUnavailableIndexPaths = [NSMutableArray new];
		self.panIndexPaths = indexPaths;
		
		NSInteger placeholderIndex = panIndexPath.item;
		self.placeholderIndexPath = [NSIndexPath indexPathForItem:placeholderIndex inSection:panIndexPath.section];
		
		[self.collectionView.visibleViews removeObjectForKey:cell.layoutAttributes.key];
		
		ASCollectionViewLayoutAttributes* layoutAttributes = [cell.layoutAttributes copy];
		layoutAttributes.transform3D = CATransform3DMakeScale(1.1, 1.1, 1);
		
		self.finalLayoutAttributes = [NSMutableDictionary new];
		for (NSIndexPath* indexPath in indexPaths) {
			ASCollectionViewLayoutAttributes* itemLayoutAttributes = [layoutAttributes copy];
			itemLayoutAttributes.alpha = 0;
			itemLayoutAttributes.indexPath = indexPath;
			self.finalLayoutAttributes[indexPath] = itemLayoutAttributes;
		}

		layoutAttributes.frame = [cell convertRect:cell.bounds toView:[self panViewContainer]];
		cell.frame = layoutAttributes.frame;
		[[self panViewContainer] addSubview:cell];
		
		[self.collectionView performBatchUpdates:^{
		} completion:^(BOOL finished) {
		}];
		
		[UIView animateWithDuration:ASCollectionViewAnimationDuration animations:^{
			[cell applyLayoutAttributes:layoutAttributes];
		}];
		if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:didStartPanWithItemsAtIndexPaths:)])
			[(id<ASCollectionViewDelegatePanLayout>) self.collectionView.delegate collectionView:self.collectionView didStartPanWithItemsAtIndexPaths:indexPaths];
	}
}

- (void) endPan {
	self.autoscrollSpeed = 0;
	
	if (self.panIndexPaths.count == 0)
		return;

	
	ASCollectionViewCell* panCell = self.panCell;
	NSMutableArray* destination = nil;
	NSMutableDictionary* indexPathsMap = [NSMutableDictionary new];

	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if (self.expandedIndexPath && [self.collectionView.delegate respondsToSelector:@selector(collectionView:didPutItemsAtIndexPaths:toItemAtIndexPath:)]) {
		[(id<ASCollectionViewDelegatePanLayout>) self.collectionView.delegate collectionView:self.collectionView didPutItemsAtIndexPaths:self.panIndexPaths toItemAtIndexPath:self.expandedIndexPath];

		ASCollectionViewLayoutAttributes* layoutAttributes = [panCell.layoutAttributes copy];
		layoutAttributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
		layoutAttributes.alpha = 0.0;
		
		[UIView animateWithDuration:ASCollectionViewAnimationDuration
						 animations:^{
							 [panCell applyLayoutAttributes:layoutAttributes];
						 } completion:^(BOOL finished) {
							 [panCell removeFromSuperview];
						 }];
		
		NSArray* panIndexPaths = self.panIndexPaths;

		self.placeholderIndexPath = nil;
		self.panIndexPaths = nil;
		self.expandedIndexPath = nil;
		
		[self.collectionView performBatchUpdates:^{
			[self.collectionView deleteItemsAtIndexPaths:panIndexPaths];
		} completion:^(BOOL finished) {
			self.panCell = nil;
		}];
	}
	else {
		if ([self canMoveItemsToIndexPath:self.placeholderIndexPath] && [self.collectionView.delegate respondsToSelector:@selector(collectionView:didMoveItemsAtIndexPaths:toIndexPaths:)]) {
			NSInteger startIndex = self.placeholderIndexPath.item;
			for (NSIndexPath* indexPath in [self.panIndexPaths reverseObjectEnumerator]) {
				if (indexPath.section == self.placeholderIndexPath.section && indexPath.item < self.placeholderIndexPath.item)
					startIndex--;
			}
			
			destination = [NSMutableArray new];
			NSInteger itemIndex = startIndex;
			NSInteger sectionIndex = self.placeholderIndexPath.section;
			
			for (NSIndexPath* indexPath in self.panIndexPaths) {
				NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:itemIndex++ inSection:sectionIndex];
				[destination addObject:newIndexPath];
				indexPathsMap[indexPath] = newIndexPath;
			}
			[(id<ASCollectionViewDelegatePanLayout>) self.collectionView.delegate collectionView:self.collectionView didMoveItemsAtIndexPaths:self.panIndexPaths toIndexPaths:destination];
		}
		else {
			destination = self.panIndexPaths;
			for (NSIndexPath* indexPath in self.panIndexPaths)
				indexPathsMap[indexPath] = indexPath;
		}
		
		ASCollectionViewLayoutAttributes* layoutAttributes = [panCell.layoutAttributes copy];
		layoutAttributes.frame = [panCell.superview convertRect:layoutAttributes.frame toView:self.collectionView];
		layoutAttributes.alpha = 0.0;
		[panCell removeFromSuperview];
		
		self.panCell.layoutAttributes.indexPath = indexPathsMap[self.panCell.layoutAttributes.indexPath];

		self.initialLayoutAttributes = [NSMutableDictionary new];
		for (NSIndexPath* indexPath in destination) {
			ASCollectionViewLayoutAttributes* itemLayoutAttributes = [layoutAttributes copy];
			itemLayoutAttributes.indexPath = indexPath;
			if ([self.panCell.layoutAttributes.indexPath isEqual:indexPath])
				itemLayoutAttributes.alpha = 1.0;
			self.initialLayoutAttributes[indexPath] = itemLayoutAttributes;
		}
		
		NSArray* panIndexPaths = self.panIndexPaths;
		self.placeholderIndexPath = nil;
		self.panIndexPaths = nil;
		self.expandedIndexPath = nil;

		[self.collectionView performBatchUpdates:^{
			int n = panIndexPaths.count;
			for (int i = 0; i < n; i++)
				[self.collectionView moveItemAtIndexPath:panIndexPaths[i] toIndexPath:destination[i]];
		} completion:^(BOOL finished) {
			self.initialLayoutAttributes = nil;
			self.panCell = nil;
		}];
	}
	
	self.placeholderAvailableIndexPaths = nil;
	self.placeholderUnavailableIndexPaths = nil;
	self.putAvailableIndexPaths = nil;
	self.putUnavailableIndexPaths = nil;
	
	self.finalLayoutAttributes = nil;
	
	if ([self.collectionView.delegate respondsToSelector:@selector(collectionViewDidFinishPan:)])
		[(id<ASCollectionViewDelegatePanLayout>) self.collectionView.delegate collectionViewDidFinishPan:self.collectionView];
}

- (void) onPan {
	NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:[self.panCell.longPressPanGestureRecognizer locationInView:self.collectionView]];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	void (^collaps)() = ^() {
		ASCollectionViewCell<ASCollectionViewCellExpanded>* cell = (ASCollectionViewCell<ASCollectionViewCellExpanded>*) [self.collectionView cellForItemAtIndexPath:self.expandedIndexPath];
		self.expandedIndexPath = nil;

		ASCollectionViewLayoutAttributes* layoutAttributes = [self.panCell.layoutAttributes copy];
		layoutAttributes.transform3D = CATransform3DMakeScale(1.1, 1.1, 1.1);
		[UIView animateWithDuration:ASCollectionViewAnimationDuration
							  delay:0
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 [self.panCell applyLayoutAttributes:layoutAttributes];
							 if ([cell respondsToSelector:@selector(setExpanded:animated:)])
								 [cell setExpanded:NO animated:YES];
						 } completion:nil];
	};

	if (indexPath) {
		ASCollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
		CGPoint p = [self.panCell.longPressPanGestureRecognizer locationInView:cell];
		CGPoint center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
		CGPoint d = CGPointMake(p.x - center.x, p.y - center.y);
		


		if ((fabs(d.x) < cell.frame.size.width / 3.0 && fabs(d.y) < cell.frame.size.height / 3.0) &&
			[self canPutItemsToIndexPath:indexPath]) {
			
			if (![indexPath isEqual:self.expandedIndexPath])
				[self performSelector:@selector(expandCellAtIndexPath:) withObject:indexPath afterDelay:0.15];
		}
		else {

			NSComparisonResult result = [self.placeholderIndexPath compare:indexPath];
			if (result == NSOrderedSame)
				result = NSOrderedAscending;
			ASCollectionViewLayoutAttributes* placeholderLayoutAttributes = [self layoutAttributesForPlaceholderInSection:self.placeholderIndexPath.section];
			CGPoint placeholderCenter = CGPointMake(placeholderLayoutAttributes.frame.origin.x + placeholderLayoutAttributes.frame.size.width / 2,
													placeholderLayoutAttributes.frame.origin.y + placeholderLayoutAttributes.frame.size.height / 2);
			
			BOOL sameRow = fabs(cell.center.y - placeholderCenter.y) < placeholderLayoutAttributes.frame.size.height / 2;
			if (((sameRow && ((result == NSOrderedAscending && d.x > 0) || (result == NSOrderedDescending && d.x < 0))) ||
				(!sameRow && ((result == NSOrderedAscending && d.y > 0) || (result == NSOrderedDescending && d.y < 0)))) &&
				[self canMoveItemsToIndexPath:indexPath]) {
				
				if (self.placeholderIndexPath)
					collaps();
				
				if (result == NSOrderedAscending)
					self.placeholderIndexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
				else
					self.placeholderIndexPath = indexPath;
				[self.collectionView performBatchUpdates:nil completion:nil];
			}
			else if (self.expandedIndexPath) {
				collaps();
				[self.collectionView performBatchUpdates:nil completion:nil];
			}
		}
	}
	else if (self.expandedIndexPath) {
		collaps();
		[self.collectionView performBatchUpdates:nil completion:nil];
	}
}

- (void) onDisplayLink:(CADisplayLink*) displayLink {
	CFTimeInterval dt = displayLink.timestamp - _lastTimestamp;
	_lastTimestamp = displayLink.timestamp;
	CGRect bounds = self.collectionView.bounds;
	bounds.origin.y += dt * self.autoscrollSpeed;
	if (bounds.origin.y < 0) {
		bounds.origin.y = 0;
		self.autoscrollSpeed = 0;
	}
	else if (bounds.origin.y > self.collectionView.contentSize.height - bounds.size.height) {
		bounds.origin.y = self.collectionView.contentSize.height - bounds.size.height;
		self.autoscrollSpeed = 0;
	}
	self.collectionView.bounds = bounds;
	if ([self.collectionView.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
		[self.collectionView.delegate scrollViewDidScroll:self.collectionView];
	[self onPan];
}

- (void) setAutoscrollSpeed:(CGFloat)autoscrollSpeed {
	_autoscrollSpeed = autoscrollSpeed;
	if (_autoscrollSpeed == 0 && self.displayLink) {
		[self.displayLink invalidate];
		self.displayLink = nil;
	}
	else if (autoscrollSpeed != 0 && !self.displayLink) {
		self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
		[self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		self.lastTimestamp = CACurrentMediaTime();
	}
}

- (BOOL) canMoveItemsToIndexPath:(NSIndexPath*) indexPath {
	BOOL canMove = NO;
	
	if (![self.placeholderUnavailableIndexPaths containsObject:indexPath]) {
		if ([self.placeholderAvailableIndexPaths containsObject:indexPath])
			canMove = YES;
		else if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:canMoveItemsAtIndexPaths:toIndexPaths:)]) {
			NSMutableArray* destination = [NSMutableArray new];
			NSInteger itemIndex = indexPath.item;
			NSInteger sectionIndex = indexPath.section;
			int n = self.panIndexPaths.count;
			for (int i = 0; i < n; i++, itemIndex++) {
				[destination addObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
			}
			if ([(id<ASCollectionViewDelegatePanLayout>) self.collectionView.delegate collectionView:self.collectionView canMoveItemsAtIndexPaths:self.panIndexPaths toIndexPaths:destination]) {
				[self.placeholderAvailableIndexPaths addObject:indexPath];
				canMove = YES;
			}
			else
				[self.placeholderUnavailableIndexPaths addObject:indexPath];
		}
		else
			[self.placeholderUnavailableIndexPaths addObject:indexPath];
	}
	return canMove;
}

- (BOOL) canPutItemsToIndexPath:(NSIndexPath*) indexPath {
	BOOL canPut = NO;
	if (![self.putUnavailableIndexPaths containsObject:indexPath]) {
		if ([self.putAvailableIndexPaths containsObject:indexPath])
			canPut = YES;
		else if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:canPutItemsAtIndexPaths:toItemAtIndexPath:)]) {
			if ([(id<ASCollectionViewDelegatePanLayout>) self.collectionView.delegate collectionView:self.collectionView canPutItemsAtIndexPaths:self.panIndexPaths toItemAtIndexPath:indexPath]) {
				[self.putAvailableIndexPaths addObject:indexPath];
				canPut = YES;
			}
			else
				[self.putUnavailableIndexPaths addObject:indexPath];
		}
		else
			[self.putUnavailableIndexPaths addObject:indexPath];
	}
	return canPut;
}

- (void) expandCellAtIndexPath:(NSIndexPath*) indexPath {
	if (![indexPath isEqual:self.expandedIndexPath]) {
		self.expandedIndexPath = indexPath;

		ASCollectionViewLayoutAttributes* layoutAttributes = [self.panCell.layoutAttributes copy];
		layoutAttributes.transform3D = CATransform3DMakeScale(0.8, 0.8, 0.8);
		
		ASCollectionViewCell<ASCollectionViewCellExpanded>* cell = (ASCollectionViewCell<ASCollectionViewCellExpanded>*) [self.collectionView cellForItemAtIndexPath:self.expandedIndexPath];
		[UIView animateWithDuration:ASCollectionViewAnimationDuration
							  delay:0
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 [self.panCell applyLayoutAttributes:layoutAttributes];
							 if ([cell respondsToSelector:@selector(setExpanded:animated:)])
								 [cell setExpanded:YES animated:YES];
						 } completion:nil];
		[self.collectionView performBatchUpdates:nil completion:nil];
	}
}

@end
