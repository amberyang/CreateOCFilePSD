//
//  YLFileProcess.m
//  ReadPSD
//
//  Created by amber on 2019/12/9.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLFileProcess.h"
#import "YLDataProcess.h"

@implementation YLFileProcess

+ (unsigned int)getUnsignedIntFromFile:(NSData *)fileData index:(NSInteger *)index length:(NSInteger)length {
    unsigned char value[length];
    [fileData getBytes:&value range:NSMakeRange(*index, length)];
    unsigned int readValue = [YLDataProcess bytesToInt:value length:length];
    *index += length;
    return readValue;
}

+ (unsigned int)getUnsignedIntFromFile:(NSData *)fileData index:(NSInteger *)index {
    unsigned char value[4] = {0};
    [fileData getBytes:&value range:NSMakeRange(*index, sizeof(value))];
    unsigned int readValue = [YLDataProcess bytesToInt:value length:sizeof(value)];
    *index += sizeof(value);
    return readValue;
}

+ (unsigned short int)getUnsignedShortIntFromFile:(NSData *)fileData index:(NSInteger *)index {
    unsigned char value[2] = {0};
    [fileData getBytes:&value range:NSMakeRange(*index, sizeof(value))];
    unsigned int readValue = [YLDataProcess bytesToInt:value length:sizeof(value)];
    *index += sizeof(value);
    return readValue;
}

+ (unsigned short int)getByteFromFile:(NSData *)fileData index:(NSInteger *)index {
    unsigned char value[1] = {0};
    [fileData getBytes:&value range:NSMakeRange(*index, sizeof(value))];
    unsigned int readValue = [YLDataProcess bytesToInt:value length:sizeof(value)];
    *index += sizeof(value);
    return readValue;
}

+ (double)getDoubleFromFile:(NSData *)fileData index:(NSInteger *)index {
    unsigned char value[8] = {0};
    [fileData getBytes:&value range:NSMakeRange(*index, sizeof(value))];
    double readValue = [YLDataProcess byteToDouble:value];
    *index += sizeof(value);
    return readValue;
}

+ (NSString *)getStringFromFile:(NSData *)fileData index:(NSInteger *)index length:(NSInteger)length encode:(NSInteger)encode {
    unsigned char name[length];
    [fileData getBytes:&name range:NSMakeRange(*index, length)];
    NSData *data = [NSData dataWithBytes:name length:length];
    NSString *string = [[NSString alloc] initWithData:data encoding:encode];
//    NSLog(@"string is %@", string);
    *index += length;
    return string;
}

+ (YLPascalString *)getUnicodeStringFromFile:(NSData *)fileData index:(NSInteger *)index {
    YLPascalString *unicodeString = [YLPascalString new];
    unsigned int length = [[self class] getUnsignedIntFromFile:fileData index:index];
        
    length *= 2;
    if (length == 0) {
        length = 2;
    } else {
//        length = (length + 3) & ~0x03;
    }
    unicodeString.length = length;
    unicodeString.text = [[self class] getStringFromFile:fileData index:index length:unicodeString.length encode:NSUnicodeStringEncoding];
    
    return unicodeString;
}

+ (YLPascalString *)getPascalStringFromFile:(NSData *)fileData index:(NSInteger *)index lengthBlock:(unsigned int(^)(unsigned int))lengthBlock encode:(NSInteger)encode {
    YLPascalString *pascalString = [YLPascalString new];
//    unsigned int length = [[self class] getUnsignedIntFromFile:fileData index:index];
    unsigned int length = [[self class] getByteFromFile:fileData index:index];
    if (lengthBlock) {
        length = lengthBlock(length);
    }
    
    pascalString.length = length;
    pascalString.text = [[self class] getStringFromFile:fileData index:index length:pascalString.length encode:encode];
    
    return pascalString;
}

+ (YLPascalString *)getIDStringFromFile:(NSData *)fileData index:(NSInteger *)index lengthBlock:(unsigned int(^)(unsigned int))lengthBlock encode:(NSInteger)encode {
    YLPascalString *pascalString = [YLPascalString new];
    unsigned int length = [[self class] getUnsignedIntFromFile:fileData index:index];
    if (lengthBlock) {
        length = lengthBlock(length);
    } else if (length == 0) {
        length = 4;
    }
    
    pascalString.length = length;
    pascalString.text = [[self class] getStringFromFile:fileData index:index length:pascalString.length encode:encode];
    
    return pascalString;
}

+ (double)getPathNumberFromFile:(NSData *)fileData index:(NSInteger *)index {
    unsigned char aVal[1] = {0};
    [fileData getBytes:&aVal range:NSMakeRange(*index, sizeof(aVal))];
    double a = 0.0;
    memcpy(&a, aVal, sizeof(float));
    *index += sizeof(aVal);
    double b = [[self class] getUnsignedIntFromFile:fileData index:index length:3];
    return a + (b/pow(2, 24));
}

@end
