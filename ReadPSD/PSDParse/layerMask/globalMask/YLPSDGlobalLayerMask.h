//
//  YLPSDGlobalLayerMask.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDGlobalLayerMaskInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDGlobalLayerMask : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDGlobalLayerMaskInfo *globalLayerMask;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
