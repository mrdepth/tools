//
//  CollapsableTableView.m
//  CollapsableTableView
//
//  Created by Artem Shimanski on 13.09.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import "CollapsableTableView.h"
#import <objc/runtime.h>

@interface CollapsableTableViewSectionIdentifier : NSObject
@property (nonatomic, assign) BOOL collapsed;
@end

@implementation CollapsableTableViewSectionIdentifier

@end

@interface SectionHeaderTapGestureRecognizer : UITapGestureRecognizer<UIGestureRecognizerDelegate>
@property (nonatomic, assign) UITableView* tableView;

@end

@implementation SectionHeaderTapGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	CGPoint p = [touch locationInView:self.tableView];
	NSInteger numberOfSections = [self.tableView numberOfSections];
	for (NSInteger section = 0; section < numberOfSections; section++)
		if (CGRectContainsPoint([self.tableView rectForHeaderInSection:section], p))
			return YES;
	return NO;
}

@end

@interface CollapsableTableView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray* sections;
@property (nonatomic, assign) BOOL updateTransaction;
@property (nonatomic, strong) NSMutableIndexSet* insertSections;
@property (nonatomic, strong) NSMutableIndexSet* deleteSections;
@property (nonatomic, strong) NSMutableArray* moveSections;

- (void) onTap:(UITapGestureRecognizer*) recognizer;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation CollapsableTableView
@synthesize delegate;
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#if ! __has_feature(objc_arc)
- (void) dealloc {
	[_sections release];
	[_insertSections release];
	[_deleteSections release];
	[_moveSections release];
	[super dealloc];
}
#endif

- (void) awakeFromNib {
	[super setDelegate:(id)self];
	[super setDataSource:(id)self];
}

- (void) reloadData {
	self.sections = nil;
	[super reloadData];
}

- (BOOL) respondsToSelector:(SEL)aSelector {
	return [CollapsableTableView instancesRespondToSelector:aSelector] || [delegate respondsToSelector:aSelector] || [dataSource respondsToSelector:aSelector];
}

- (id) forwardingTargetForSelector:(SEL)aSelector {
	if ([delegate respondsToSelector:aSelector])
		return delegate;
	else if ([dataSource respondsToSelector:aSelector])
		return dataSource;
	else
		return nil;
}

- (void) setDelegate:(id<CollapsableTableViewDelegate>)value {
	if ((id) value != self)
		delegate = value;
	else
		[super setDelegate:value];
}

- (void) setDataSource:(id<UITableViewDataSource>)value {
	if ((id) value != self)
		dataSource = value;
	else
		[super setDataSource:value];
}

- (id<UITableViewDataSource>) dataSource {
	return [super dataSource];
}

- (id<CollapsableTableViewDelegate>) delegate {
	return (id<CollapsableTableViewDelegate>) [super delegate];
}

- (void) beginUpdates {
	[super beginUpdates];
	self.updateTransaction = YES;
	self.insertSections = [NSMutableIndexSet indexSet];
	self.deleteSections = [NSMutableIndexSet indexSet];
	self.moveSections = [NSMutableArray array];
}

- (void) endUpdates {
	[self.sections removeObjectsAtIndexes:self.deleteSections];

	NSInteger number = [self.insertSections count];
	NSMutableArray* objects = [NSMutableArray array];
	for (NSInteger i = 0; i < number; i++)
		[objects addObject:[NSNull null]];
	[self.sections insertObjects:objects atIndexes:self.insertSections];

	[super endUpdates];
	self.updateTransaction = NO;
	self.insertSections = nil;
	self.deleteSections = nil;
	self.moveSections = nil;
}

- (void) insertSections:(NSIndexSet *)aSections withRowAnimation:(UITableViewRowAnimation)animation {
	if (self.updateTransaction) {
		[self.insertSections addIndexes:aSections];
	}
	else {
		NSInteger number = [aSections count];
		NSMutableArray* objects = [NSMutableArray array];
		for (NSInteger i = 0; i < number; i++)
			[objects addObject:[NSNull null]];
		[self.sections insertObjects:objects atIndexes:aSections];
	}
	[super insertSections:aSections withRowAnimation:animation];
}

- (void) deleteSections:(NSIndexSet *)aSections withRowAnimation:(UITableViewRowAnimation)animation {
	if (self.updateTransaction)
		[self.deleteSections addIndexes:aSections];
	else
		[self.sections removeObjectsAtIndexes:aSections];
	[super deleteSections:aSections withRowAnimation:animation];
}

- (void) moveSection:(NSInteger)section toSection:(NSInteger)newSection {
	if ([super respondsToSelector:@selector(moveSection:toSection:)]) {
		if (self.updateTransaction)
			[self.moveSections addObject:@{@"from" : @(section), @"to" : @(newSection)}];
		[super moveSection:section toSection:newSection];
	}
}

- (NSMutableArray*) sections {
	if (!_sections) {
		NSInteger numberOfSections = [self numberOfSections];
		self.sections = [NSMutableArray arrayWithCapacity:numberOfSections];
		for (NSInteger section = 0; section < numberOfSections; section++)
			[self.sections addObject:[NSNull null]];
	}
	return _sections;
}

/*- (void) handleShake {
	if (![delegate respondsToSelector:@selector(tableView:canCollapsSection:)])
		return;
	
	NSInteger n = self.sections.count;
	BOOL allCollapsed = YES;
	for (NSInteger sectionIndex = 0; sectionIndex < n; sectionIndex++) {
		BOOL collapsed;
		if ([self.sections objectAtIndex:sectionIndex] == [NSNull null]) {
			if ([self.delegate respondsToSelector:@selector(tableView:sectionIsCollapsed:)])
				collapsed = [delegate tableView:self sectionIsCollapsed:sectionIndex];
			else
				collapsed =  NO;
			[self.sections replaceObjectAtIndex:sectionIndex withObject:@(collapsed)];
		}
		else
			collapsed = [[self.sections objectAtIndex:sectionIndex] boolValue];
		
		if ([delegate tableView:self canCollapsSection:sectionIndex]) {
			if (!collapsed) {
				allCollapsed = NO;
				break;
			}
		}
	}
	
	NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
	if ([delegate respondsToSelector:@selector(tableView:canCollapsSection:)]) {
		for (NSInteger sectionIndex = 0; sectionIndex < n; sectionIndex++) {
			if ([delegate tableView:self canCollapsSection:sectionIndex]) {
				[self.sections replaceObjectAtIndex:sectionIndex withObject:@(!allCollapsed)];
				if (allCollapsed && [delegate respondsToSelector:@selector(tableView:didExpandSection:)])
					[delegate tableView:self didExpandSection:sectionIndex];
				else if (!allCollapsed && [delegate respondsToSelector:@selector(tableView:didCollapsSection:)])
					[delegate tableView:self didCollapsSection:sectionIndex];
				
				[indexSet addIndex:sectionIndex];
			}
		}
	}
	if (indexSet.count > 0)
		[self reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}*/

- (void) collapsAll {
	if (![delegate respondsToSelector:@selector(tableView:canCollapsSection:)])
		return;
	
	NSInteger n = self.sections.count;
	
	NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
	for (NSInteger sectionIndex = 0; sectionIndex < n; sectionIndex++) {
		if ([delegate tableView:self canCollapsSection:sectionIndex]) {
			CollapsableTableViewSectionIdentifier* identifier = self.sections[sectionIndex];
			if ((NSNull*) identifier == [NSNull null]) {
				identifier = [CollapsableTableViewSectionIdentifier new];
				[self.sections replaceObjectAtIndex:sectionIndex withObject:identifier];
			}
			identifier.collapsed = YES;
			
			if ([delegate respondsToSelector:@selector(tableView:didCollapsSection:)])
				[delegate tableView:self didCollapsSection:sectionIndex];
			[indexSet addIndex:sectionIndex];
		}
	}
	if (indexSet.count > 0)
		[self reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

- (void) expandAll {
	if (![delegate respondsToSelector:@selector(tableView:canCollapsSection:)])
		return;
	
	NSInteger n = self.sections.count;
	
	NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
	for (NSInteger sectionIndex = 0; sectionIndex < n; sectionIndex++) {
		if ([delegate tableView:self canCollapsSection:sectionIndex]) {
			CollapsableTableViewSectionIdentifier* identifier = self.sections[sectionIndex];
			if ((NSNull*) identifier == [NSNull null]) {
				identifier = [CollapsableTableViewSectionIdentifier new];
				[self.sections replaceObjectAtIndex:sectionIndex withObject:identifier];
			}
			identifier.collapsed = NO;

			if ([delegate respondsToSelector:@selector(tableView:didExpandSection:)])
				[delegate tableView:self didExpandSection:sectionIndex];
			[indexSet addIndex:sectionIndex];
		}
	}
	if (indexSet.count > 0)
		[self reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	CollapsableTableViewSectionIdentifier* identifier = self.sections[section];
	if ((NSNull*) identifier == [NSNull null]) {
		identifier = [CollapsableTableViewSectionIdentifier new];
		if ([self.delegate respondsToSelector:@selector(tableView:sectionIsCollapsed:)])
			identifier.collapsed = [delegate tableView:tableView sectionIsCollapsed:section];
		else
			identifier.collapsed =  NO;
		[self.sections replaceObjectAtIndex:section withObject:identifier];
	}
	if (identifier.collapsed)
		return 0;
	else
		return [dataSource tableView:tableView numberOfRowsInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if ([delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
		UIView* view = [delegate tableView:self viewForHeaderInSection:section];
		if (!view)
			return nil;
		CollapsableTableViewSectionIdentifier* identifier = self.sections[section];
		if ((NSNull*) identifier == [NSNull null]) {
			identifier = [CollapsableTableViewSectionIdentifier new];
			if ([self.delegate respondsToSelector:@selector(tableView:sectionIsCollapsed:)])
				identifier.collapsed = [delegate tableView:tableView sectionIsCollapsed:section];
			else
				identifier.collapsed =  NO;
			[self.sections replaceObjectAtIndex:section withObject:identifier];
		}

		if ([view respondsToSelector:@selector(setCollapsed:)]) {
			[(id)view setCollapsed:identifier.collapsed];
		}
		
		UIGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
		[view addGestureRecognizer:recognizer];
#if ! __has_feature(objc_arc)
		[recognizer release];
#endif
		objc_setAssociatedObject(view, @"identifier", identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		
		return view;
	}
	else
		return nil;
}

#pragma mark - Private

- (void) onTap:(UITapGestureRecognizer *)recognizer {
	CollapsableTableViewSectionIdentifier* identifier = objc_getAssociatedObject(recognizer.view, @"identifier");
	if (identifier) {
		NSInteger sectionIndex = [self.sections indexOfObject:identifier];
		if (sectionIndex == NSNotFound)
			return;
		
		if (![delegate respondsToSelector:@selector(tableView:canCollapsSection:)] || [delegate tableView:self canCollapsSection:sectionIndex]) {
			if (identifier.collapsed && [delegate respondsToSelector:@selector(tableView:didExpandSection:)])
				[delegate tableView:self didExpandSection:sectionIndex];
			else if (!identifier.collapsed && [delegate respondsToSelector:@selector(tableView:didCollapsSection:)])
				[delegate tableView:self didCollapsSection:sectionIndex];
			identifier.collapsed = !identifier.collapsed;
			[self reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}

@end

#pragma clang diagnostic pop