//
//  ASTreeController.m
//  ASTreeController
//
//  Created by Shimanski Artem on 03.03.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "ASTreeController.h"


@interface ASTreeControllerNode : NSObject {
	NSNumber* _expanded;
	NSNumber* _expandable;
}
@property (assign, getter = isExpanded) BOOL expanded;
@property (readonly, getter = isExpandable) BOOL expandable;
@property (nonatomic, strong) id item;
@property (nonatomic, strong) NSMutableArray* children;
@property (nonatomic, weak) ASTreeController* treeController;
@property (nonatomic, weak) ASTreeControllerNode* parent;
@property (nonatomic, assign) NSInteger indentationLevel;
@property (nonatomic, assign) NSInteger index;

- (void) insertChildren:(nonnull NSIndexSet*) indexes;
- (void) removeChildren:(nonnull NSIndexSet*) indexes;
@end

@implementation ASTreeControllerNode

- (NSArray*) children {
	if (!_children) {
		NSMutableArray* array = [NSMutableArray new];
		NSInteger n = [self.treeController.delegate treeController:self.treeController numberOfChildrenOfItem:self.item];
		for (NSInteger i = 0; i < n; i++) {
			ASTreeControllerNode* node = [ASTreeControllerNode new];
			node.treeController = self.treeController;
			node.parent = self;
			node.index = i;
			node.indentationLevel = self.indentationLevel + 1;
			
			[array addObject:node];
		}
		_children = array;
	}
	return _children;
}

- (id) item {
	if (!_item && self.parent) {
		_item = [self.treeController.delegate treeController:self.treeController child:self.index ofItem:self.parent.item];
	}
	return _item;
}

- (BOOL) isExpandable {
	if (!_expandable) {
		if ([self.treeController.delegate respondsToSelector:@selector(treeController:isItemExpandable:)])
			_expandable = @([self.treeController.delegate treeController:self.treeController isItemExpandable:self.item]);
		else
			_expandable = @(YES);
	}
	return [_expandable boolValue];
}

- (BOOL) isExpanded {
	if (!_expanded) {
		if ([self.treeController.delegate respondsToSelector:@selector(treeController:isItemExpanded:)])
			_expanded = @([self.treeController.delegate treeController:self.treeController isItemExpanded:self.item]);
		else
			_expanded = @(YES);
	}
	return [_expanded boolValue];
}

- (void) setExpanded:(BOOL)expanded {
	_expanded = @(expanded);
}

- (void) insertChildren:(nonnull NSIndexSet*) indexes {
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
		ASTreeControllerNode* node = [ASTreeControllerNode new];
		node.treeController = self.treeController;
		node.parent = self;
		node.index = idx;
		node.indentationLevel = self.indentationLevel + 1;
		
		[_children insertObject:node atIndex:idx];
	}];
}

- (void) removeChildren:(nonnull NSIndexSet*) indexes {
	[_children removeObjectsAtIndexes:indexes];
}


@end

@interface ASTreeController()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) ASTreeControllerNode* root;
@property (nonatomic, assign) NSInteger numberOfRows;

- (ASTreeControllerNode*) nodeWithIndexPath:(NSIndexPath*) indexPath;
- (ASTreeControllerNode*) nodeWithItem:(id) item;
- (NSIndexPath*) indexPathForNodeWithItem:(id) item;
- (NSInteger) numberOfRowsWithNode:(ASTreeControllerNode*) node;
@end


@implementation ASTreeController

- (id) init {
	if (self = [super init]) {
		self.numberOfRows = -1;
	}
	return self;
}

- (void) reloadRowsWithItems:(NSArray*) items withRowAnimation:(UITableViewRowAnimation)animation {
	NSMutableArray* indexPaths = [NSMutableArray new];
	for (id item in items)
		[indexPaths addObject:[self indexPathForNodeWithItem:item]];
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void) insertChildren:(nonnull NSIndexSet*) indexes ofItem:(nullable id) item withRowAnimation:(UITableViewRowAnimation)animation {
	NSIndexPath* indexPath = [self indexPathForNodeWithItem:item];
	ASTreeControllerNode* node = [self nodeWithItem:item];
	
	NSAssert([self.delegate treeController:self numberOfChildrenOfItem:item] == node.children.count + indexes.count, nil);
	
	[node insertChildren:indexes];

	if (!item || (indexPath && node.expanded)) {
		NSMutableArray* indexPaths = [NSMutableArray new];

		NSInteger idx = item ? indexPath.row + 1 : 0;
		NSInteger to = [indexes lastIndex];
		for (NSInteger i = 0; i <= to; i++) {
			ASTreeControllerNode* child = node.children[i];
			idx++;
			if (child.expanded) {
				NSInteger n = [self numberOfRowsWithNode:node.children[i]];
				if ([indexes containsIndex:i]) {
					[indexPaths addObject:[NSIndexPath indexPathForRow:idx - 1 inSection:0]];
					for (NSInteger j = 0; j < n; j++)
						[indexPaths addObject:[NSIndexPath indexPathForRow:idx + j inSection:0]];
				}
				idx += n;
			}
		}
		
		_numberOfRows = -1;
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
	}
}

- (void) removeChildren:(nonnull NSIndexSet*) indexes ofItem:(nullable id) item withRowAnimation:(UITableViewRowAnimation)animation {
	NSIndexPath* indexPath = [self indexPathForNodeWithItem:item];
	ASTreeControllerNode* node = [self nodeWithItem:item];
	
	NSAssert([self.delegate treeController:self numberOfChildrenOfItem:item] == node.children.count - indexes.count, nil);
	
	if (!item || (indexPath && node.expanded)) {
		NSMutableArray* indexPaths = [NSMutableArray new];
		
		NSInteger idx = item ? indexPath.row + 1 : 0;
		NSInteger to = [indexes lastIndex];
		for (NSInteger i = 0; i <= to; i++) {
			ASTreeControllerNode* child = node.children[i];
			idx++;
			if (child.expanded) {
				NSInteger n = [self numberOfRowsWithNode:node.children[i]];
				if ([indexes containsIndex:i]) {
					[indexPaths addObject:[NSIndexPath indexPathForRow:idx - 1 inSection:0]];
					for (NSInteger j = 0; j < n; j++)
						[indexPaths addObject:[NSIndexPath indexPathForRow:idx + j inSection:0]];
				}
				idx += n;
			}
		}
		
		[node removeChildren:indexes];

		_numberOfRows = -1;
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
	}
	else
		[node removeChildren:indexes];
}

- (BOOL) isItemExpanded:(nonnull id) item {
	ASTreeControllerNode* node = [self nodeWithItem:item];
	return node.expanded;
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSections {
	return 1;
}

- (NSInteger) tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.numberOfRows;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ASTreeControllerNode* node = [self nodeWithIndexPath:indexPath];
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[self.delegate treeController:self cellIdentifierForItem:node.item] forIndexPath:indexPath];
	cell.indentationLevel = node.indentationLevel;
	if ([self.delegate respondsToSelector:@selector(treeController:configureCell:withItem:)])
		[self.delegate treeController:self configureCell:cell withItem:node.item];

	return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ASTreeControllerNode* node = [self nodeWithIndexPath:indexPath];
	if (node.children.count > 0 && node.expandable) {
		
		__block NSInteger row = indexPath.row;
		NSMutableArray* indexPaths = [NSMutableArray new];
		
		__block __weak void (^weakEnumerate)(ASTreeControllerNode*);
		void (^enumerate)(ASTreeControllerNode*) = ^(ASTreeControllerNode* node) {
			for (ASTreeControllerNode* child in node.children) {
				[indexPaths addObject:[NSIndexPath indexPathForRow:++row inSection:0]];
				if (child.expanded)
					weakEnumerate(child);
			}
		};
		weakEnumerate = enumerate;
		enumerate(node);
		node.expanded = !node.expanded;
		
		if (node.expanded) {
			self.numberOfRows += indexPaths.count;
			[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
			
			if ([self.delegate respondsToSelector:@selector(treeController:didExpandCell:withItem:)])
				[self.delegate treeController:self didExpandCell:[tableView cellForRowAtIndexPath:indexPath] withItem:node.item];
		}
		else {
			self.numberOfRows -= indexPaths.count;
			[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
			
			if ([self.delegate respondsToSelector:@selector(treeController:didCollapseCell:withItem:)])
				[self.delegate treeController:self didCollapseCell:[tableView cellForRowAtIndexPath:indexPath] withItem:node.item];
		}
	}
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(treeController:estimatedHeightForRowWithItem:)])
		return [self.delegate treeController:self estimatedHeightForRowWithItem:[self nodeWithIndexPath:indexPath].item];
	else
		return tableView.estimatedRowHeight > 0 ? tableView.estimatedRowHeight : -1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(treeController:heightForRowWithItem:)])
		return [self.delegate treeController:self heightForRowWithItem:[self nodeWithIndexPath:indexPath].item];
	else {
		if (tableView.estimatedRowHeight > 0 || [self.delegate respondsToSelector:@selector(treeController:estimatedHeightForRowWithItem:)])
			return UITableViewAutomaticDimension;
		else
			return self.tableView.rowHeight;
	}
}

#pragma mark - Private

- (ASTreeControllerNode*) nodeWithIndexPath:(NSIndexPath*) indexPath {
	__block NSInteger row = indexPath.row;
	
	__block __weak ASTreeControllerNode* (^weakEnumerate)(ASTreeControllerNode*);
	ASTreeControllerNode* (^enumerate)(ASTreeControllerNode*) = ^(ASTreeControllerNode* node) {
		if (node.expanded) {
			for (ASTreeControllerNode* child in node.children) {
				if (row == 0)
					return child;
				row--;
				ASTreeControllerNode* node = weakEnumerate(child);
				if (node)
					return node;
			}
		}
		return (ASTreeControllerNode*) nil;
	};
	weakEnumerate = enumerate;
	return enumerate(self.root);
}

- (ASTreeControllerNode*) nodeWithItem:(id) item {
	if (!item)
		return self.root;
	
	__block __weak ASTreeControllerNode* (^weakEnumerate)(ASTreeControllerNode*);
	ASTreeControllerNode* (^enumerate)(ASTreeControllerNode*) = ^(ASTreeControllerNode* node) {
		for (ASTreeControllerNode* child in node.children) {
			if ([child.item isEqual:item])
				return child;
			ASTreeControllerNode* node = weakEnumerate(child);
			if (node)
				return node;
		}
		return (ASTreeControllerNode*) nil;
	};
	weakEnumerate = enumerate;
	return enumerate(self.root);
}

- (NSIndexPath*) indexPathForNodeWithItem:(id) item {
	__block NSInteger row = 0;
	
	__block __weak ASTreeControllerNode* (^weakEnumerate)(ASTreeControllerNode*);
	ASTreeControllerNode* (^enumerate)(ASTreeControllerNode*) = ^(ASTreeControllerNode* node) {
		if (node.expanded) {
			for (ASTreeControllerNode* child in node.children) {
				if ([child.item isEqual:item])
					return child;
				row++;
				ASTreeControllerNode* node = weakEnumerate(child);
				if (node)
					return node;
			}
		}
		return (ASTreeControllerNode*) nil;
	};
	weakEnumerate = enumerate;
	ASTreeControllerNode* node = enumerate(self.root);
	if (node)
		return [NSIndexPath indexPathForRow:row inSection:0];
	else
		return nil;
}

- (ASTreeControllerNode*) root {
	if (!_root) {
		_root = [ASTreeControllerNode new];
		_root.treeController = self;
		_root.expanded = YES;
	}
	return _root;
}

- (NSInteger) numberOfRows {
	if (_numberOfRows < 0) {
		_numberOfRows = [self numberOfRowsWithNode:self.root];
	}
	return _numberOfRows;
}

- (NSInteger) numberOfRowsWithNode:(ASTreeControllerNode*) node {
	__block NSInteger numberOfRows = 0;
	
	__block __weak void (^weakEnumerate)(ASTreeControllerNode*);
	void (^enumerate)(ASTreeControllerNode*) = ^(ASTreeControllerNode* node) {
		if (node.expanded) {
			numberOfRows += node.children.count;
			for (ASTreeControllerNode* child in node.children)
				weakEnumerate(child);
		}
	};
	weakEnumerate = enumerate;
	enumerate(node);
	return numberOfRows;
}

@end
