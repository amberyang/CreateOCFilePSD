//
//  YLPSDColorModeData.h
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDColorModeInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDColorModeData : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDColorModeInfo *colorModeInfo;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index colorMode:(unsigned int)colorMode;

@end

NS_ASSUME_NONNULL_END
