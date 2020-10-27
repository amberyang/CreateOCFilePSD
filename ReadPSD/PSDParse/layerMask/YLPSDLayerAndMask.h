//
//  YLPSDLayerAndMask.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDLayerAndMaskInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDLayerAndMask : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDLayerAndMaskInfo *layerMaskInfo;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index
      channel:(unsigned int)channel colorMode:(NSInteger)colorMode;

@end

NS_ASSUME_NONNULL_END
