//
//  YLPSDAdditionalLayerInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDAdditionalLayerInfo : YLPSDBaseSection

@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) unsigned int length;
@property (nonatomic, strong) NSDictionary *result;

@end

NS_ASSUME_NONNULL_END
