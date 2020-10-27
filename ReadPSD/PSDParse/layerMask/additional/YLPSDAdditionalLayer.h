//
//  YLPSDAdditionalLayer.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDAdditionalLayerInfo.h"

@class YLPSDLayerRecordInfo;

@interface YLPSDAdditionalLayer : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDAdditionalLayerInfo *adjustment;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index record:(YLPSDLayerRecordInfo *)record;

@end
