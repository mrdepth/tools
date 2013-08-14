//
//  ASCollectionViewLayoutAttributes.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ASCollectionElementCategoryCell,
    ASCollectionElementCategorySupplementaryView,
    ASCollectionElementCategoryDecorationView
} ASCollectionElementCategory;

@interface ASCollectionViewLayoutAttributes : NSObject<NSCopying>
@property (nonatomic) CGRect frame;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGSize size;
@property (nonatomic) CATransform3D transform3D;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) NSInteger zIndex; // default is 0
@property (nonatomic, getter=isHidden) BOOL hidden; // As an optimization, UICollectionView might not create a view for items whose hidden attribute is YES
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, readonly) id key;
@property (nonatomic, assign) BOOL shouldScroll;

@property (nonatomic, assign) ASCollectionElementCategory representedElementCategory;
@property (nonatomic, copy) NSString *representedElementKind; // nil when representedElementCategory is UICollectionElementCategoryCell

+ (id) keyForElementAtIndexPath:(NSIndexPath*) indexPath withElementCategory:(ASCollectionElementCategory) elementCategory elementKind:(NSString*) elementKind;
+ (id) keyForItemAtIndexPath:(NSIndexPath*) indexPath;

@end
