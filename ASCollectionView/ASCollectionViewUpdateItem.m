//
//  ASCollectionViewUpdateItem.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionViewUpdateItem.h"

@implementation ASCollectionViewUpdateItem

- (id)initWithInitialIndexPath:(NSIndexPath*) initialIndexPath
				finalIndexPath:(NSIndexPath*) finalIndexPath
				  updateAction:(ASCollectionUpdateAction) updateAction {
	if (self = [super init]) {
		self.indexPathBeforeUpdate = initialIndexPath;
		self.indexPathAfterUpdate = finalIndexPath;
		self.updateAction = updateAction;
	}
	return self;
}

- (id)initWithAction:(ASCollectionUpdateAction)updateAction forIndexPath:(NSIndexPath *)indexPath {
    if (updateAction == ASCollectionUpdateActionInsert)
        return [self initWithInitialIndexPath:nil finalIndexPath:indexPath updateAction:updateAction];
    else if (updateAction == ASCollectionUpdateActionDelete)
        return [self initWithInitialIndexPath:indexPath finalIndexPath:nil updateAction:updateAction];
    else if (updateAction == ASCollectionUpdateActionReload)
        return [self initWithInitialIndexPath:indexPath finalIndexPath:indexPath updateAction:updateAction];
	
    return nil;
}

- (BOOL) isSectionUpdate {
	return self.indexPathBeforeUpdate.item == NSNotFound || self.indexPathAfterUpdate.item == NSNotFound;
}

- (NSComparisonResult) compareToDelete:(ASCollectionViewUpdateItem*) other {
	if (_indexPathBeforeUpdate && other.indexPathBeforeUpdate)
		return [other.indexPathBeforeUpdate compare:_indexPathBeforeUpdate];
	else if (_indexPathBeforeUpdate)
		return NSOrderedDescending;
	else
		return NSOrderedAscending;
}

- (NSComparisonResult) compareToInsert:(ASCollectionViewUpdateItem*) other {
	if (_indexPathAfterUpdate && other.indexPathAfterUpdate)
		return [_indexPathAfterUpdate compare:other.indexPathAfterUpdate];
	else if (_indexPathAfterUpdate)
		return NSOrderedAscending;
	else
		return NSOrderedDescending;
}

@end
