//
//  NSString+UTI.h
//  MyFolder
//
//  Created by Artem Shimanski on 23.05.12.
//  Copyright (c) 2012 Belprog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UTI)
- (BOOL) isImageFile;
- (BOOL) isVideoFile;
- (NSString*) fileMIMEType;
- (NSString*) fileUTI;

@end
