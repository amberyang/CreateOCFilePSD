//
//  YLPSDLayerMaskInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLPSDLayerMaskInfo : YLPSDBaseSection

@property (nonatomic, assign) unsigned int size;
@property (nonatomic, assign) UIEdgeInsets layerMaskInsets;
@property (nonatomic, assign) unsigned short int color;
@property (nonatomic, assign) unsigned short int flags;
@property (nonatomic, assign) unsigned short int param;

@end

NS_ASSUME_NONNULL_END
