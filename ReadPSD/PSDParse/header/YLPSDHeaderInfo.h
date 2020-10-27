//
//  YLPSDHeaderInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDHeaderInfo : YLPSDBaseSection

@property (nonatomic, copy) NSString *signature;
@property (nonatomic, assign) unsigned int version;
@property (nonatomic, assign) unsigned int reserved;
@property (nonatomic, assign) unsigned int channels;
@property (nonatomic, assign) unsigned int height;
@property (nonatomic, assign) unsigned int width;
@property (nonatomic, assign) unsigned short int depth;
@property (nonatomic, assign) unsigned short int colorMode;

@end

NS_ASSUME_NONNULL_END
