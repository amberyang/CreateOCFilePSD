//
//  YLEffectLayerInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/9.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLEffectLayerInfo : YLPSDBaseSection

@property (nonatomic, assign) unsigned int size;
@property (nonatomic, assign) unsigned int version;
@property (nonatomic, assign) unsigned int blur;
@property (nonatomic, assign) unsigned int intensity;
@property (nonatomic, strong) NSDictionary *result;

@end

NS_ASSUME_NONNULL_END
