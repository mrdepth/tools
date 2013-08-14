//
//  ASLongPressPanGestureRecognizer.h
//  ASCollectionView
//
//  Created by Artem Shimanski on 06.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASLongPressPanGestureRecognizer : UILongPressGestureRecognizer

- (CGPoint)translationInView:(UIView *)view;
- (void)setTranslation:(CGPoint)translation inView:(UIView *)view;
- (CGPoint)velocityInView:(UIView *)view;

@end
