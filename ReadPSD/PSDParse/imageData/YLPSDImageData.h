//
//  YLPSDImageData.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDImageDataInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDImageData : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDImageDataInfo *imageData;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index
      channel:(unsigned int)channel colorMode:(NSInteger)colorMode
        width:(unsigned int)width height:(unsigned int)height;

@end

NS_ASSUME_NONNULL_END
