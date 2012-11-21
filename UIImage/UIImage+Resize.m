//
//  UIImage+Resize.m
//  PhotoPlus
//
//  Created by Shimanski on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (CGAffineTransform)transformForOrientation:(UIImageOrientation) orientation size:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown: 
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
		default:
			break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
		default:
			break;
    }
    
    return transform;
}

- (UIImage*) scaledImageToSize:(CGSize)newSize scalingMode:(ScalingMode) scalingMode interpolationQuality:(CGInterpolationQuality) quality scale:(CGFloat) scale {
	BOOL transpose;
	switch (self.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transpose = YES;
			break;
		default:
			transpose = NO;
			break;
	}
	int mirrorV = 1;
	int mirrorH = 1;
	switch (self.imageOrientation) {
		case UIImageOrientationUp:
			mirrorH = 1;
			mirrorV = -1;
			break;
		case UIImageOrientationRight:
			mirrorH = 1;
			mirrorV = 1;
			break;
		case UIImageOrientationDown:
			mirrorH = -1;
			mirrorV = 1;
			break;
		case UIImageOrientationLeft:
			mirrorH = -1;
			mirrorV = -1;
			break;
		case UIImageOrientationDownMirrored:
			mirrorH = 1;
			mirrorV = 1;
			break;
		case UIImageOrientationUpMirrored:
			mirrorH = -1;
			mirrorV = -1;
			break;
		case UIImageOrientationRightMirrored:
			mirrorH = -1;
			mirrorV = 1;
			break;
		case UIImageOrientationLeftMirrored:
			mirrorH = 1;
			mirrorV = -1;
			break;
		default:
			break;
	}
	
	CGSize size;
	CGRect rect;
	
	if (scalingMode == ScalingModeFill) {
		size = newSize;
	}
	else if (scalingMode == ScalingModeAspectFit) {
		CGSize oldSize = self.size;
		float aspectOld = oldSize.width / oldSize.height;
		float aspectNew = newSize.width / newSize.height;
		float scale = aspectOld > aspectNew ? newSize.width / oldSize.width : newSize.height / oldSize.height;
		size = CGSizeMake(oldSize.width * scale, oldSize.height * scale);
		newSize = size;
	}
	else if (scalingMode == ScalingModeAspectFill) {
		CGSize oldSize = self.size;
		float aspectOld = oldSize.width / oldSize.height;
		float aspectNew = newSize.width / newSize.height;
		float scale = aspectOld < aspectNew ? newSize.width / oldSize.width : newSize.height / oldSize.height;
		size = CGSizeMake(oldSize.width * scale, oldSize.height * scale);
	}
	else if (scalingMode == ScalingModeAspectExtendsFit) {
		CGSize oldSize = self.size;
		float aspectOld = oldSize.width / oldSize.height;
		float aspectNew = newSize.width / newSize.height;
		float scale = aspectOld > aspectNew ? newSize.width / oldSize.width : newSize.height / oldSize.height;
		size = CGSizeMake(oldSize.width * scale, oldSize.height * scale);
	}
	else if (scalingMode == ScalingModeAspectExtendsFill) {
		CGSize oldSize = self.size;
		float aspectOld = oldSize.width / oldSize.height;
		float aspectNew = newSize.width / newSize.height;
		float scale = aspectOld < aspectNew ? newSize.width / oldSize.width : newSize.height / oldSize.height;
		size = CGSizeMake(oldSize.width * scale, oldSize.height * scale);
		newSize = size;
	}
	rect = transpose ?
		CGRectMake((newSize.height - size.height) / 2 * mirrorH, (newSize.width - size.width) / 2 * mirrorV, size.height, size.width) :
		CGRectMake((newSize.width - size.width) / 2 * mirrorH, (newSize.height - size.height) / 2 * mirrorV, size.width, size.height);

	UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
	
	CGContextSetInterpolationQuality(context, quality);
	CGContextConcatCTM(context, [self transformForOrientation:self.imageOrientation size:size]);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1, -1);
	CGContextDrawImage(context, rect, [self CGImage]);
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end