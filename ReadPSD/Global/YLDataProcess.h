//
//  YLDataProcess.h
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLDataProcess : NSObject


+ (int)bytesToInt:(unsigned char *)bytes length:(size_t)length;

+ (int)bytesToInt:(unsigned char *)bytes length:(size_t)length sign:(BOOL)hasSign;

+ (double)byteToDouble:(unsigned char *)bytes;

+ (BOOL)arrayContainString:(NSArray *)array string:(NSString *)string;

+ (UIFont *)adjustsFontSize:(UILabel *)label;

@end

NS_ASSUME_NONNULL_END
