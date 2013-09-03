//
//  NSObject+Debug.h
//  EVEUniverse
//
//  Created by Artem Shimanski on 03.09.13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Debug)
+ (NSArray*) allMethods;
+ (NSArray*) allProperties;
+ (NSArray*) allIvars;
@end
