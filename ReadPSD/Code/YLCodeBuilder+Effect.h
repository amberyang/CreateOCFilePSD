//
//  YLCodeBuilder+Effect.h
//  ReadPSD
//
//  Created by amber on 2020/6/8.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLCodeBuilder.h"

@interface YLCodeBuilder (Effect)

+ (NSString *)addEffectGradient:(CALayer *)contentLayer gradient:(CAGradientLayer **)gradient
                   record:(YLPSDLayerRecordInfo *)record mixColor:(YLRGBA *)mixColor
                       viewName:(NSString *)viewName;

+ (NSString *)addEffectOverlayRGBA:(CALayer *)contentLayer overlayer:(CALayer **)overlayer
                      record:(YLPSDLayerRecordInfo *)record;

+ (NSString *)addEffectStoke:(CALayer *)contentLayer record:(YLPSDLayerRecordInfo *)record viewName:(NSString *)viewName;

+ (NSArray<NSValue *> *)getPoint:(CGFloat)angl;

@end
