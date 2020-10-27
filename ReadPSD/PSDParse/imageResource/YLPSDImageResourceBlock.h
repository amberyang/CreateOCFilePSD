//
//  YLPSDImageResourceBlock.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDImageResourceBlockInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDImageResourceBlock : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDImageResourceBlockInfo *blockInfo;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
