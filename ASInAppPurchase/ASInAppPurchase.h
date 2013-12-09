//
//  ASInAppPurchase.h
//  ASInAppPurchase
//
//  Created by Artem Shimanski on 09.12.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASInAppPurchase : NSObject
@property (nonatomic, copy, readonly) NSString* productID;
@property (nonatomic, assign) BOOL purchased;

+ (id) inAppPurchaseWithProductID:(NSString*) productID;
- (id) initWithProductID:(NSString*) productID;

@end
