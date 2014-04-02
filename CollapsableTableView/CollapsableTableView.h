//
//  CollapsableTableView.h
//  CollapsableTableView
//
//  Created by Artem Shimanski on 13.09.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollapsableView <NSObject>
@property (nonatomic, assign) BOOL collapsed;


@end

@protocol CollapsableTableViewDelegate <UITableViewDelegate>
@optional
- (BOOL) tableView:(UITableView *)tableView sectionIsCollapsed:(NSInteger) section;
- (BOOL) tableView:(UITableView *)tableView canCollapsSection:(NSInteger) section;
- (void) tableView:(UITableView *)tableView didCollapsSection:(NSInteger) section;
- (void) tableView:(UITableView *)tableView didExpandSection:(NSInteger) section;

@end


@interface CollapsableTableView : UITableView
@property (nonatomic, weak) id<CollapsableTableViewDelegate> delegate;
@property (nonatomic, weak) id<UITableViewDataSource> dataSource;

//- (void) handleShake;
- (void) collapsAll;
- (void) expandAll;

@end
