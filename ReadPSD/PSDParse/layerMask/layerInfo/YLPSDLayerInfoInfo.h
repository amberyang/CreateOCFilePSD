//
//  YLPSDLayerInfoInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDLayerRecordInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDLayerInfoInfo : YLPSDBaseSection

@property (nonatomic, assign) unsigned int length;
@property (nonatomic, assign) unsigned int layerCount;
@property (nonatomic, strong) NSArray<YLPSDLayerRecordInfo *> *records;

@end

NS_ASSUME_NONNULL_END
