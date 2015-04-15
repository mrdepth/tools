//
//  ASInAppPurchase.m
//  ASInAppPurchase
//
//  Created by Artem Shimanski on 09.12.13.
//  Copyright (c) 2013 Artem Shimanski. All rights reserved.
//

#import "ASInAppPurchase.h"

@interface ASInAppPurchase()
@property (nonatomic, copy, readwrite) NSString* productID;
@property (nonatomic, strong) NSDictionary* query;

@end

@implementation ASInAppPurchase

+ (instancetype) inAppPurchaseWithProductID:(NSString*) productID {
	return [[ASInAppPurchase alloc] initWithProductID:productID];
}

- (id) initWithProductID:(NSString*) productID {
	if (self = [super init]) {
		self.productID = productID;

		NSDictionary* query = @{(__bridge id) kSecAttrService: productID,
								(__bridge id) kSecMatchLimit: (__bridge id) kSecMatchLimitOne,
								(__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
								(__bridge id) kSecReturnAttributes: (__bridge id) kCFBooleanTrue,
								(__bridge id) kSecReturnData: (__bridge id) kCFBooleanTrue};

		CFTypeRef dicRef = nil;

		OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &dicRef);
		if (status == errSecSuccess || status == errSecItemNotFound) {
			if (dicRef) {
				NSMutableDictionary* query = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*) dicRef];
				query[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;
				
				NSData* data = query[(__bridge id) kSecValueData];
				
				const int32_t *v = (int32_t*) [data bytes];
				_purchased = *v;
				
				[query removeObjectForKey:(__bridge id) kSecReturnData];
				self.query = query;
				CFRelease(dicRef);
			}
			else
				_purchased = NO;
		}
		else
			return nil;
	}
	return self;
}

- (void) setPurchased:(BOOL)purchased {
	_purchased = purchased;
	int32_t v = _purchased;
	NSData* data = [NSData dataWithBytes:&v length:sizeof(int32_t)];
	
	if (self.query) {
		if (_purchased)
			SecItemUpdate((__bridge CFDictionaryRef) self.query, (__bridge CFDictionaryRef) @{(__bridge id) kSecValueData: data});
		else
			SecItemDelete((__bridge CFDictionaryRef) self.query);
	}
	else {
		NSDictionary* attr = @{(__bridge id) kSecAttrService: self.productID,
							   (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
							   (__bridge id) kSecValueData: data,
							   (__bridge id) kSecReturnAttributes: (__bridge id) kCFBooleanTrue};

		CFTypeRef dicRef = nil;
		SecItemAdd((__bridge CFDictionaryRef)attr, &dicRef);
		if (dicRef) {
			NSMutableDictionary* query = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*) dicRef];
			query[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;
			[query removeObjectForKey:(__bridge id) kSecReturnData];
			self.query = query;
			CFRelease(dicRef);
		}
	}
}

@end
