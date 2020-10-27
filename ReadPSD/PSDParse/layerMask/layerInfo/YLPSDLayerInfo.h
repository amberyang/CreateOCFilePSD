//
//  YLPSDLayerInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDLayerInfoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDLayerInfo : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDLayerInfoInfo *layerInfo;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index channel:(unsigned int)channel colorMode:(NSInteger)colorMode;

@end

NS_ASSUME_NONNULL_END
