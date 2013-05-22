//
//  UIActionSheet+Block.h
//  MyFolder
//
//  Created by Artem Shimanski on 17.08.12.
//
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (Block)<UIActionSheetDelegate>
+ (id)actionSheetWithTitle:(NSString *)title
		 cancelButtonTitle:(NSString *)cancelButtonTitle
	destructiveButtonTitle:(NSString *)destructiveButtonTitle
		 otherButtonTitles:(NSArray *)otherButtonTitles
		   completionBlock:(void (^)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex)) completionBlock
			   cancelBlock:(void (^)()) cancelBlock;

- (id)   initWithTitle:(NSString *)title
	 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
	 otherButtonTitles:(NSArray *)otherButtonTitles
	   completionBlock:(void (^)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex)) completionBlock
		   cancelBlock:(void (^)()) cancelBlock;

+ (id)actionSheetWithStyle:(UIActionSheetStyle) style
					 title:(NSString *)title
		 cancelButtonTitle:(NSString *)cancelButtonTitle
	destructiveButtonTitle:(NSString *)destructiveButtonTitle
		 otherButtonTitles:(NSArray *)otherButtonTitles
		   completionBlock:(void (^)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex)) completionBlock
			   cancelBlock:(void (^)()) cancelBlock;

- (id)   initWithStyle:(UIActionSheetStyle) style
				 title:(NSString *)title
	 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
	 otherButtonTitles:(NSArray *)otherButtonTitles
	   completionBlock:(void (^)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex)) completionBlock
		   cancelBlock:(void (^)()) cancelBlock;


@end
