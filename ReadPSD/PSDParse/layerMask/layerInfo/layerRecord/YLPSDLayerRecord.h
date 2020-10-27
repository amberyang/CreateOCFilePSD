//
//  YLPSDLayerRecord.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDLayerRecordInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDLayerRecord : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDLayerRecordInfo *record;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
