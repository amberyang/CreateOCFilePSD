//
//  YLPSDChannel.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDChannelInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDChannel : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDChannelInfo *channelInfo;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
