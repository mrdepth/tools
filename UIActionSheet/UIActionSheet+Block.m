//
//  UIActionSheet+Block.m
//  MyFolder
//
//  Created by Artem Shimanski on 17.08.12.
//
//

#import "UIActionSheet+Block.h"
#import <objc/runtime.h>

@interface UIActionSheet()
@property (nonatomic, copy) void (^completionBlock)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex);
@property (nonatomic, copy) void (^cancelBlock)();
@end

@implementation UIActionSheet (Block)

+ (id)actionSheetWithTitle:(NSString *)title
		 cancelButtonTitle:(NSString *)cancelButtonTitle
	destructiveButtonTitle:(NSString *)destructiveButtonTitle
		 otherButtonTitles:(NSArray *)otherButtonTitles
		   completionBlock:(void (^)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex)) completionBlock
			   cancelBlock:(void (^)()) cancelBlock {
#if ! __has_feature(objc_arc)
	return [[[UIActionSheet alloc] initWithTitle:title
							   cancelButtonTitle:cancelButtonTitle
						  destructiveButtonTitle:destructiveButtonTitle
							   otherButtonTitles:otherButtonTitles
								 completionBlock:completionBlock
									 cancelBlock:cancelBlock] autorelease];
#else
	return [[UIActionSheet alloc] initWithTitle:title
							  cancelButtonTitle:cancelButtonTitle
						 destructiveButtonTitle:destructiveButtonTitle
							  otherButtonTitles:otherButtonTitles
								completionBlock:completionBlock
									cancelBlock:cancelBlock];
#endif
}

- (id)   initWithTitle:(NSString *)title
	 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
	 otherButtonTitles:(NSArray *)otherButtonTitles
	   completionBlock:(void (^)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex)) completionBlock
		   cancelBlock:(void (^)()) cancelBlock {
	if (self = [self initWithTitle:title
						  delegate:self
				 cancelButtonTitle:nil
			destructiveButtonTitle:nil
				 otherButtonTitles:nil]) {
		self.completionBlock = completionBlock;
		self.cancelBlock = cancelBlock;

		if (destructiveButtonTitle) {
			[self addButtonWithTitle:destructiveButtonTitle];
			self.destructiveButtonIndex = 0;
		}
		for (NSString* title in otherButtonTitles)
			[self addButtonWithTitle:title];
		if (cancelButtonTitle) {
			[self addButtonWithTitle:cancelButtonTitle];
			self.cancelButtonIndex = self.numberOfButtons - 1;
		}
	}
	return self;
}

+ (id)actionSheetWithStyle:(UIActionSheetStyle) style
					 title:(NSString *)title
		 cancelButtonTitle:(NSString *)cancelButtonTitle
	destructiveButtonTitle:(NSString *)destructiveButtonTitle
		 otherButtonTitles:(NSArray *)otherButtonTitles
		   completionBlock:(void (^)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex)) completionBlock
			   cancelBlock:(void (^)()) cancelBlock {
#if ! __has_feature(objc_arc)
	return [[[UIActionSheet alloc] initWithStyle:style
										   title:title
							   cancelButtonTitle:cancelButtonTitle
						  destructiveButtonTitle:destructiveButtonTitle
							   otherButtonTitles:otherButtonTitles
								 completionBlock:completionBlock
									 cancelBlock:cancelBlock] autorelease];
#else
	return [[UIActionSheet alloc] initWithStyle:style
										  title:title
							  cancelButtonTitle:cancelButtonTitle
						 destructiveButtonTitle:destructiveButtonTitle
							  otherButtonTitles:otherButtonTitles
								completionBlock:completionBlock
									cancelBlock:cancelBlock];
#endif
}

- (id)   initWithStyle:(UIActionSheetStyle) style
				 title:(NSString *)title
	 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
	 otherButtonTitles:(NSArray *)otherButtonTitles
	   completionBlock:(void (^)(UIActionSheet* actionSheet, NSInteger selectedButtonIndex)) completionBlock
		   cancelBlock:(void (^)()) cancelBlock {
	if (self = [self initWithTitle:title
				 cancelButtonTitle:cancelButtonTitle
			destructiveButtonTitle:destructiveButtonTitle
				 otherButtonTitles:otherButtonTitles
				   completionBlock:completionBlock
					   cancelBlock:cancelBlock]) {
		self.actionSheetStyle = style;
	}
	return self;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (self.completionBlock) {
		self.completionBlock(self, buttonIndex);
		self.completionBlock = nil;
	}
	self.cancelBlock = nil;
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	if (self.cancelBlock) {
		self.cancelBlock();
		self.cancelBlock = nil;
	}
	self.completionBlock = nil;
}

#pragma mark - Private

- (void) setCompletionBlock:(void (^)(UIActionSheet*, NSInteger))completionBlock {
	objc_setAssociatedObject(self, @"completionBlock", [completionBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void(^)(UIActionSheet*, NSInteger)) completionBlock {
	return objc_getAssociatedObject(self, @"completionBlock");
}

- (void) setCancelBlock:(void (^)())cancelBlock {
	objc_setAssociatedObject(self, @"cancelBlock", [cancelBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void(^)()) cancelBlock {
	return objc_getAssociatedObject(self, @"cancelBlock");
}

@end
