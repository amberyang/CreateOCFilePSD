//
//  YLEffect.h
//  ReadPSD
//
//  Created by amber on 2019/12/20.
//  Copyright © 2019 amber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLGradient.h"
#import "YLInsideShadow.h"
#import "YLEffectStroke.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLEffect : NSObject

@property (nonatomic, strong) YLGradient *gradient;
@property (nonatomic, strong) YLRGBA *rgba;
@property (nonatomic, strong) YLInsideShadow *irsh;
@property (nonatomic, strong) YLEffectStroke *frfx;

+ (id)getDataWithArray:(NSArray *)array key:(NSArray *)keys;

@end

NS_ASSUME_NONNULL_END
