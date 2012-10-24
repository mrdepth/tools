//
//  UITableViewCell+Nib.h
//  SettingsKit
//
//  Created by Artem Shimanski on 17.08.12.
//  Copyright (c) 2012 Artem Shimanski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Nib)
+ (id) cellWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle reuseIdentifier:(NSString *)reuseIdentifier;

@end
