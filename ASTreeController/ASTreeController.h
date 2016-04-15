//
//  ASTreeController.h
//  ASTreeController
//
//  Created by Shimanski Artem on 03.03.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASTreeController;
@protocol ASTreeControllerDelegate <NSObject>

@required
- (nonnull id)treeController:(nonnull ASTreeController *)treeController child:(NSInteger)index ofItem:(nullable id)item;
- (NSInteger) treeController:(nonnull ASTreeController *)treeController numberOfChildrenOfItem:(nullable id)item;
- (nonnull NSString*) treeController:(nonnull ASTreeController *)treeController cellIdentifierForItem:(nonnull id) item;

@optional
- (void) treeController:(nonnull ASTreeController *)treeController configureCell:(nonnull __kindof UITableViewCell*) cell withItem:(nonnull id) item;
- (BOOL) treeController:(nonnull ASTreeController *)treeController isItemExpandable:(nonnull id)item;
- (BOOL) treeController:(nonnull ASTreeController *)treeController isItemExpanded:(nonnull id)item;
- (CGFloat) treeController:(nonnull ASTreeController *)treeController estimatedHeightForRowWithItem:(nonnull id) item;
- (CGFloat) treeController:(nonnull ASTreeController *)treeController heightForRowWithItem:(nonnull id) item;
- (void) treeController:(nonnull ASTreeController *)treeController didExpandCell:(nonnull __kindof UITableViewCell*) cell withItem:(nonnull id)item;
- (void) treeController:(nonnull ASTreeController *)treeController didCollapseCell:(nonnull __kindof UITableViewCell*) cell withItem:(nonnull id)item;

@end

@interface ASTreeController : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nullable, weak, nonatomic) IBOutlet id<ASTreeControllerDelegate> delegate;
@property (nullable, weak, nonatomic) IBOutlet UITableView* tableView;

- (void) reloadRowsWithItems:(nonnull NSArray*) items withRowAnimation:(UITableViewRowAnimation)animation;
- (void) insertChildren:(nonnull NSIndexSet*) indexes ofItem:(nullable id) item withRowAnimation:(UITableViewRowAnimation)animation;
- (void) removeChildren:(nonnull NSIndexSet*) indexes ofItem:(nullable id) item withRowAnimation:(UITableViewRowAnimation)animation;
- (BOOL) isItemExpanded:(nonnull id) item;

@end
