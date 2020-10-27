//
//  YLBGRGBA.h
//  ReadPSD
//
//  Created by amber on 2019/12/18.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLRGBA.h"
#import "YLEffect.h"
#import "YLCircularRadius.h"
#import "YLStroke.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLBGRGBA : YLRGBA

@property (nonatomic, assign) BOOL sameColor;
@property (nonatomic, assign) BOOL sameRGB;
@property (nonatomic, strong) YLGradient *gradient;
@property (nonatomic, strong) YLCircularRadius *circular;
@property (nonatomic, strong) YLEffect *effect;
@property (nonatomic, strong) YLStroke *stoke;

@end

NS_ASSUME_NONNULL_END
