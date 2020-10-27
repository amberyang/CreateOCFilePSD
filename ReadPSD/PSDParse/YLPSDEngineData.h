//
//  YLPSDEngineData.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDEngineData : YLPSDBaseSection

- (NSDictionary *)parseEngineData:(unsigned char *)tdta length:(NSInteger)length;

@end

NS_ASSUME_NONNULL_END
