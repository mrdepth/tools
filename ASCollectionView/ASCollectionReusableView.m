//
//  ASCollectionReusableView.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 29.07.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASCollectionReusableView.h"
#import <QuartzCore/QuartzCore.h>
#import "ASCollectionView.h"

@interface ASCollectionReusableView()
@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;
@property (nonatomic, strong, readwrite) ASCollectionViewLayoutAttributes* layoutAttributes;
@end

@implementation ASCollectionReusableView

- (id) initWithReuseIdentifier:(NSString*) reuseIdentifier {
	if (self = [super init]) {
		self.reuseIdentifier = reuseIdentifier;
	}
	return self;
}

- (void)applyLayoutAttributes:(ASCollectionViewLayoutAttributes *)layoutAttributes {
	if (_layoutAttributes != layoutAttributes) {
		self.layoutAttributes = layoutAttributes;
		
		self.bounds = (CGRect) {.origin = CGPointZero, .size = layoutAttributes.frame.size};
		CGPoint center = CGPointMake(CGRectGetMidX(layoutAttributes.frame), CGRectGetMidY(layoutAttributes.frame));
		if (!layoutAttributes.shouldScroll) {
			center.x += self.collectionView.contentOffset.x;
			center.y += self.collectionView.contentOffset.y;
		}
		self.center = center;
		//self.frame = layoutAttributes.frame;
		self.layer.transform = layoutAttributes.transform3D;
		self.alpha = layoutAttributes.alpha;
		self.layer.zPosition = layoutAttributes.zIndex;
		[self setNeedsLayout];
	}
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
