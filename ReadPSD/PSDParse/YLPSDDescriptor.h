//
//  YLPSDDescriptor.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLTextInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDDescriptor : YLPSDBaseSection

@property (nonatomic, strong, readonly) NSDictionary *result;

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
