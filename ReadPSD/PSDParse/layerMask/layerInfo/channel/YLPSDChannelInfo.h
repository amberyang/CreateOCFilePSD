//
//  YLPSDChannelInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDChannelInfo : YLPSDBaseSection

@property (nonatomic, assign) short int channelId;
@property (nonatomic, assign) unsigned int length;

@end

NS_ASSUME_NONNULL_END
