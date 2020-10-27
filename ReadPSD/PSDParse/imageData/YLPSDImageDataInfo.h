//
//  YLPSDImageDataInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDImageDataInfo : YLPSDBaseSection

@property (nonatomic, assign) unsigned short int compression;
@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
