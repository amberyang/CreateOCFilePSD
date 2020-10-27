//
//  YLDataProcess.m
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLDataProcess.h"

@implementation YLDataProcess

#pragma mark ---- data change
+ (int)bytesToInt:(unsigned char *)bytes length:(size_t)length {
    return [[self class] bytesToInt:bytes length:length sign:NO];
}

+ (int)bytesToInt:(unsigned char *)bytes length:(size_t)length sign:(BOOL)hasSign {
    BOOL isNegative = NO;
    int result = 0;
    for (int i=0; i<length; i++) {
        if (hasSign && i ==0) {
            if (bytes[i] >= 0xA) {
                isNegative = YES;
            }
        }
        if (isNegative) {
            result += (((~bytes[i]) & 0x00FF) << (8*(length-i-1)));
        } else {
            result += (bytes[i] << (8*(length-i-1)));
        }
    }
    if (isNegative) {
        result += 1;
        result = -result;
    }
    return result;
}

+ (double)byteToDouble:(unsigned char *)bytes {
    for (NSInteger j=0; j<4; j++) {
        unsigned char temp = bytes[j];
        bytes[j] = bytes[7-j];
        bytes[7-j] = temp;
    }
    double value = 0.0;
    memcpy(&value, bytes, sizeof(double));
    return value;
}

+ (BOOL)arrayContainString:(NSArray *)array string:(NSString *)string {
    BOOL isContain = NO;
    for (NSString *value in array) {
        if ([string isEqualToString:value]) {
            isContain = YES;
            break;
        }
    }
    return isContain;
}


//+ (unsigned int *)intToBytes:(long long)number length:(size_t)length {
//    NSInteger count = length * 8;
//    unsigned int *result[count];
//    for (int i=0; i<count; i++) {
//        result[i] = (unsigned int *)(number & (0xFF >> i) >> (8*i));
//    }
//    return *result;
//}


+ (UIFont *)adjustsFontSize:(UILabel *)label {
    float curFontSize = label.font.pointSize;
    UIFont *font = label.font;
    
    CGRect rect;
    rect = [label bounds];
    if (rect.size.width == 0.0f || rect.size.height == 0.0f) {
        return 0;
    }
    
    while (curFontSize > label.minimumScaleFactor && curFontSize > 0.0f) {
        CGSize size = CGSizeZero;
        
        //  A single line of text should be clipped
        if (label.numberOfLines == 1) {
            size = [label.text boundingRectWithSize:CGSizeMake(rect.size.width, 0.0f)
                                                  options:NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName:font}
                                                  context:NULL].size;
    
        } else {
            //Multiple lines of text should be wrapped
                    size = [label.text boundingRectWithSize:CGSizeMake(rect.size.width, 0.0f)
                                                          options:NSStringDrawingUsesFontLeading
                                                       attributes:@{NSFontAttributeName:font}
                                                          context:NULL].size;
        }
        
        if (size.width < rect.size.width && size.height <= rect.size.height) {
            break;
        }
        
        curFontSize -= 1.0f;
        font = [font fontWithSize:curFontSize];
    }
    
    if (curFontSize < label.minimumScaleFactor) {
        curFontSize = label.minimumScaleFactor;
    }
    if (curFontSize < 0.0f) {
        curFontSize = 1.0f;
    }
    
    font = [font fontWithSize:curFontSize];
    
    return font;
}

@end
