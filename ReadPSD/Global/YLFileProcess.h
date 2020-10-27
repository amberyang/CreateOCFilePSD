//
//  YLFileProcess.h
//  ReadPSD
//
//  Created by amber on 2019/12/9.
//  Copyright © 2019 amber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLPascalString.h"

@interface YLFileProcess : NSObject

+ (unsigned int)getUnsignedIntFromFile:(NSData *)fileData index:(NSInteger *)index;

+ (unsigned short int)getUnsignedShortIntFromFile:(NSData *)fileData index:(NSInteger *)index;

+ (unsigned short int)getByteFromFile:(NSData *)fileData index:(NSInteger *)index;

+ (double)getDoubleFromFile:(NSData *)fileData index:(NSInteger *)index;

+ (NSString *)getStringFromFile:(NSData *)fileData index:(NSInteger *)index
                         length:(NSInteger)length encode:(NSInteger)encode;

+ (unsigned int)getUnsignedIntFromFile:(NSData *)fileData index:(NSInteger *)index
                                length:(NSInteger)length;

+ (YLPascalString *)getUnicodeStringFromFile:(NSData *)fileData index:(NSInteger *)index;

+ (YLPascalString *)getPascalStringFromFile:(NSData *)fileData index:(NSInteger *)index lengthBlock:(unsigned int(^)(unsigned int))lengthBlock encode:(NSInteger)encode;

+ (YLPascalString *)getIDStringFromFile:(NSData *)fileData index:(NSInteger *)index lengthBlock:(unsigned int(^)(unsigned int))lengthBlock encode:(NSInteger)encode;

+ (double)getPathNumberFromFile:(NSData *)fileData index:(NSInteger *)index;

@end
