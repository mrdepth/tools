//
//  ASLongPressPanGestureRecognizer.m
//  ASCollectionView
//
//  Created by Artem Shimanski on 06.08.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASLongPressPanGestureRecognizer.h"

@interface UILongPressGestureRecognizer()
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface ASLongPressPanGestureRecognizer() {
    CGPoint _firstScreenLocation;
    CGPoint _lastScreenLocation;
}

@end

@implementation ASLongPressPanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	UITouch* touch = [touches anyObject];
	_firstScreenLocation = [touch locationInView:nil];
	_lastScreenLocation = _firstScreenLocation;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	UITouch* touch = [touches anyObject];
	_lastScreenLocation = [touch locationInView:nil];
}

- (CGPoint)translationInView:(UIView *)view {
	CGPoint first;
	CGPoint last;
	if (view) {
		first = [view convertPoint:_firstScreenLocation fromView:nil];
		last = [view convertPoint:_lastScreenLocation fromView:nil];
	}
	else {
		first = _firstScreenLocation;
		last = _lastScreenLocation;
	}
	return CGPointMake(last.x - first.x, last.y - first.y);
}

- (void)setTranslation:(CGPoint)translation inView:(UIView *)view {
	if (view)
		translation = [view convertPoint:translation toView:nil];
	_firstScreenLocation.x = _lastScreenLocation.x - translation.x;
	_firstScreenLocation.y = _lastScreenLocation.y - translation.x;
}

- (CGPoint)velocityInView:(UIView *)view {
	return CGPointZero;
}

@end
