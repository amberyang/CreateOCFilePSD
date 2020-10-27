//
//  YLPSDImageResourceBlockInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPascalString.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDImageResourceBlockInfo : YLPSDBaseSection

@property (nonatomic, copy) NSString *signature;
@property (nonatomic, assign) unsigned short int resourceId;
@property (nonatomic, strong) YLPascalString *name;
@property (nonatomic, assign) unsigned int size;

@end

NS_ASSUME_NONNULL_END
