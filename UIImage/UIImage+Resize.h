//
//  UIImage+Resize.h
//  PhotoPlus
//
//  Created by Shimanski on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ScalingModeFill = 0,
	ScalingModeAspectFit,
	ScalingModeAspectFill,
	ScalingModeAspectExtendsFit,
	ScalingModeAspectExtendsFill
} ScalingMode;

@interface UIImage(Resize)

- (UIImage*) scaledImageToSize:(CGSize)newSize scalingMode:(ScalingMode) scalingMode interpolationQuality:(CGInterpolationQuality) quality scale:(CGFloat) scale;

@end
