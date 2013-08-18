//
//  ASCaptionTextField.m
//  EVEUniverse
//
//  Created by mr_depth on 18.08.13.
//
//

#import "ASCaptionTextField.h"

@implementation ASCaptionTextField

- (UILabel*) captionLabel {
	if (!_captionLabel) {
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
		_captionLabel.textColor = [UIColor blackColor];
		self.leftView = _captionLabel;
		self.leftViewMode = UITextFieldViewModeAlways;
	}
	return _captionLabel;
}

- (void) setCaption:(NSString *)caption {
	self.captionLabel.text = caption;
}

- (NSString*) caption {
	return self.captionLabel.text;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
	CGRect r;
	r.size = [_captionLabel sizeThatFits:bounds.size];
	r.size.width += 5;
	r.size.height = bounds.size.height - 2;
	r.origin = CGPointMake(10, 0);
	return r;
}

@end
