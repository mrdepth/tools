//
//  ASCollectionViewFlowLayoutItem.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 01.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASCollectionViewFlowLayoutItem : NSObject<NSCopying>
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) NSIndexPath* indexPath;

@end
