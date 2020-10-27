//
//  YLPSDImageResourceInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDImageResourceBlockInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDImageResourceInfo : YLPSDBaseSection

@property (nonatomic, assign) unsigned int length;
@property (nonatomic, strong) NSArray<YLPSDImageResourceBlockInfo *> *blocks;

@end

NS_ASSUME_NONNULL_END
