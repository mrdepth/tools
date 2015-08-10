//
//  NSDictionary+XML.h
//  Tools
//
//  Created by Артем Шиманский on 07.08.15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (XML)

+ (instancetype) dictionaryWithXMLData:(NSData*) data;

@end
