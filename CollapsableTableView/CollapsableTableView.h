//
//  CollapsableTableView.h
//  CollapsableTableView
//
//  Created by Artem Shimanski on 13.09.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollapsableTableViewDelegate <UITableViewDelegate>
@optional
- (BOOL) tableView:(UITableView *)tableView sectionIsCollapsed:(NSInteger) section;
- (BOOL) tableView:(UITableView *)tableView canCollapsSection:(NSInteger) section;
- (void) tableView:(UITableView *)tableView didCollapsSection:(NSInteger) section;
- (void) tableView:(UITableView *)tableView didExpandSection:(NSInteger) section;

@end


@interface CollapsableTableView : UITableView
@property (nonatomic, assign) id<CollapsableTableViewDelegate> delegate;
@property (nonatomic, assign) id<UITableViewDataSource> dataSource;

- (void) handleShake;

@end
