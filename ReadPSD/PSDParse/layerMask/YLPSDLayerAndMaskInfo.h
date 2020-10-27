//
//  YLPSDLayerAndMaskInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDAdditionalLayerInfo.h"
#import "YLPSDLayerInfoInfo.h"
#import "YLPSDGlobalLayerMaskInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDLayerAndMaskInfo : YLPSDBaseSection

@property (nonatomic, assign) unsigned int length;
@property (nonatomic, strong) YLPSDLayerInfoInfo *layerInfos;
@property (nonatomic, strong) YLPSDGlobalLayerMaskInfo *globalLayerMask;
@property (nonatomic, strong) NSArray<YLPSDAdditionalLayerInfo *> *adjustmentLayers;

@end

NS_ASSUME_NONNULL_END
