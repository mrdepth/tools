//
//  UIAlertView+Block.h
//  
//
//  Created by Artem Shimanski on 14.08.12.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Block)<UIAlertViewDelegate>
+ (id)alertViewWithTitle:(NSString *)title
				 message:(NSString *)message
	   cancelButtonTitle:(NSString *)cancelButtonTitle
	   otherButtonTitles:(NSArray*) titles
		 completionBlock:(void (^)(UIAlertView* alertView, NSInteger selectedButtonIndex)) completionBlock
			 cancelBlock:(void (^)()) cancelBlock;

- (id)initWithTitle:(NSString *)title
			message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSArray*) titles
	completionBlock:(void (^)(UIAlertView* alertView, NSInteger selectedButtonIndex)) completionBlock
		cancelBlock:(void (^)()) cancelBlock;

- (id)initWithTitle:(NSString *)title
			message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSArray*) titles
	completionBlock:(void (^)(UIAlertView* alertView, NSInteger selectedButtonIndex)) completionBlock
		cancelBlock:(void (^)()) cancelBlock
    didDismissBlock:(void (^)(UIAlertView* alertView, NSInteger selectedButtonIndex)) didDismissBlock;

@end
