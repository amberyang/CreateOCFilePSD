//
//  YLPSDHeader.h
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDHeaderInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDHeader : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDHeaderInfo *headerInfo;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
