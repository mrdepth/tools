//
//  ASCollectionViewUpdateItem.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ASCollectionUpdateActionInsert,
    ASCollectionUpdateActionDelete,
    ASCollectionUpdateActionReload,
    ASCollectionUpdateActionMove,
    ASCollectionUpdateActionNone
} ASCollectionUpdateAction;

@interface ASCollectionViewUpdateItem : NSObject

@property (nonatomic, strong) NSIndexPath *indexPathBeforeUpdate; // nil for UICollectionUpdateActionInsert
@property (nonatomic, strong) NSIndexPath *indexPathAfterUpdate; // nil for UICollectionUpdateActionDelete
@property (nonatomic, assign) ASCollectionUpdateAction updateAction;

- (id)initWithInitialIndexPath:(NSIndexPath*) initialIndexPath
				finalIndexPath:(NSIndexPath*) finalIndexPath
				  updateAction:(ASCollectionUpdateAction) updateAction;
- (id)initWithAction:(ASCollectionUpdateAction)updateAction forIndexPath:(NSIndexPath *)indexPath;

- (BOOL) isSectionUpdate;

- (NSComparisonResult) compareToDelete:(ASCollectionViewUpdateItem*) other;
- (NSComparisonResult) compareToInsert:(ASCollectionViewUpdateItem*) other;

@end
