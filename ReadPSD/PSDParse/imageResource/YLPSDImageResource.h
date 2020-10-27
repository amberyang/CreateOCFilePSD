//
//  YLPSDImageResource.h
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDImageResourceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDImageResource : YLPSDBaseSection

@property (nonatomic, strong, readonly) YLPSDImageResourceInfo *imageResourceInfo;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
