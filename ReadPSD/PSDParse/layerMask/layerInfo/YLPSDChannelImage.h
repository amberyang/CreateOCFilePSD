//
//  YLPSDChannelImage.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDChannelInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDChannelImage : YLPSDBaseSection

+ (NSMutableArray *)channelImageDataForCompression:(NSInteger)compression
                                       channelInfo:(YLPSDChannelInfo *)channelInfo
                                          fileData:(NSData *)fileData
                                         colorMode:(NSInteger)colorMode
                                      currentIndex:(NSInteger)index
                                            offset:(NSInteger)offset
                                              size:(CGSize)size
                                         imageData:(NSMutableArray *)currentData
                                          endIndex:(NSInteger *)endIndex;

+ (NSMutableArray *)imageDataForData:(unsigned int *)lines
                         channelInfo:(YLPSDChannelInfo *)channelInfo
                           colorMode:(NSInteger)colorMode
                                size:(CGSize)size
                           imageData:(NSMutableArray *)currentData;

@end

NS_ASSUME_NONNULL_END
