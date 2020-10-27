//
//  YLCodeBuilder+Effect.m
//  ReadPSD
//
//  Created by amber on 2020/6/8.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLRGBA.h"
#import "YLCodeBuilder+Effect.h"
#import "YLMethodManager.h"

@implementation YLCodeBuilder (Effect)

+ (NSString *)addEffectGradient:(CALayer *)contentLayer gradient:(CAGradientLayer **)gradient
                   record:(YLPSDLayerRecordInfo *)record mixColor:(YLRGBA *)mixColor
                       viewName:(NSString *)viewName {
    
    NSString *code = @"";
    
    NSInteger overlayRGBAIndex = 0;
    [record getOverlayRGBA:&overlayRGBAIndex];
    
    NSInteger overlayGradientIndex = 0;
    YLGradient *overlayGradient = [record getOverlayGradient:&overlayGradientIndex];
    
    if (overlayGradientIndex >= overlayRGBAIndex && overlayGradientIndex > 0 && contentLayer) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = contentLayer.bounds;

        CGFloat angl = overlayGradient.angl/180.0*M_PI;
        if (overlayGradient.rvrs) {
            angl = (overlayGradient.angl+180.0)/180.0*M_PI;
        }
        
        NSArray<NSValue *> *points = [[self class] getPoint:angl];

        gradientLayer.startPoint = [[points objectAtIndex:0] CGPointValue];
        gradientLayer.endPoint = [[points objectAtIndex:1] CGPointValue];
        
        NSMutableArray *locas = [NSMutableArray array];
        NSMutableArray *colors = [NSMutableArray array];
        
        NSString *locasString = @"NSArray<NSNumber *> *locations = [NSArray arrayWithObjects:";
        NSString *colorsString = @"NSArray<UIColor *> *color = [NSArray arrayWithObjects:";
        
        for (YLRGBAGradient *rgba in overlayGradient.gradients) {
            rgba.alpha = rgba.alpha * (overlayGradient.opct / 100.0);
            UIColor *color;
            if (mixColor) {
                color = [YLRGBA colorWithRGBA:mixColor overlay:rgba];
            }
            if (!color) {
                color = [YLRGBA colorWithRGBA:rgba];
            }
            [colors addObject:(id)color.CGColor];
            [locas addObject:@(rgba.position)];
            
            YLRGBA *resultRGB = [YLRGBA rgbaColorFromUIColor:color];
            
            locasString = [locasString stringByAppendingFormat:@"@(%.1f),",rgba.position];
            colorsString = [colorsString stringByAppendingFormat:@"(id)%@.CGColor,",[self colorStringWithRGBA:resultRGB]];
        }
        gradientLayer.colors = colors;
        gradientLayer.locations = locas;
        
        locasString = [locasString stringByAppendingString:@"nil"];
        colorsString = [colorsString stringByAppendingString:@"nil"];
        
        code = [code stringByAppendingFormat:@"%@\n%@\n",locasString,colorsString];
        
        if (contentLayer.cornerRadius > 0) {
            gradientLayer.cornerRadius = contentLayer.cornerRadius;
        } else if (record.bgColor.circular) {
            gradientLayer.cornerRadius = [record.bgColor.circular cornerRadius];
        }
        
        if (gradient) {
            *gradient = gradientLayer;
        }
        
        NSString *viewName = [[self class] replaceSpecialWord:record.name.text];
        NSString *cornerRadius = (gradientLayer.cornerRadius > 0)?[NSString stringWithFormat:@"%@_overGrad.cornerRadius = %.1f;\n",viewName,gradientLayer.cornerRadius]:@"";
                
        NSString *overlayCode = [NSString stringWithFormat:@"CAGradientLayer *overlayGradient = [CAGradientLayer layer];\n"
                              "overlayGradient.frame = frame;\n"
                              "overlayGradient.startPoint = startPoint;\n"
                              "overlayGradient.endPoint = endPoint;\n"
                              "overlayGradient.colors = colors;\n"
                              "overlayGradient.locations = locations;\n"
                              "return overlayGradient;\n"];
        
        [[YLMethodManager shareInstance] insertGlobalMethod:@"+ (CAGradientLayer *)getOverlayGradient:(NSArray<UIColor *> *)colors locations:(NSArray<NSString *> *)locations startPoint:(CGPoint *)startPoint endPoint:(CGPoint *)endPoint frame:(CGRect)frame" content:overlayCode viewClass:@"GlobalMethod" superClass:@"NSObject" record:record];
        
        code = [code stringByAppendingFormat:@"%@ = [GlobalMethod getOverlayGradient:colors locations:locations startPoint:CGPointMake(%.1f,%.1f) endPoint:CGPointMake(%.1f,%.1f)  frame:CGRectMake(0,0,%.1f,%.1f)];\n%@",viewName,gradientLayer.startPoint.x,gradientLayer.startPoint.y,
                gradientLayer.endPoint.x,gradientLayer.endPoint.y,
                gradientLayer.bounds.size.width,gradientLayer.bounds.size.height,cornerRadius];
    }
    return code;
}

+ (NSString *)addEffectOverlayRGBA:(CALayer *)contentLayer overlayer:(CALayer **)overlayer
                      record:(YLPSDLayerRecordInfo *)record {
    
    NSString *code = @"";
    if (record.bgColor.effect.rgba) {
        CALayer *overlay = [[CALayer alloc] init];
        [overlay setFrame:contentLayer.bounds];
        [overlay setBackgroundColor:[YLRGBA colorWithRGBA:record.bgColor.effect.rgba].CGColor];
        
        NSString *overlayCode = [NSString stringWithFormat:@"CALayer *overlayRGBA = [[CALayer alloc] init];\n"
                                 "[overlayRGBA setFrame:frame];\n"
                                 "[overlayRGBA setBackgroundColor:color.CGColor];\n"
                                 "return overlayRGBA;\n"];
        
        [[YLMethodManager shareInstance] insertGlobalMethod:@"+ (CALayer *)getOverlayRGBA:(UIColor *)color frame:(CGRect)frame" content:overlayCode viewClass:@"GlobalMethod" superClass:@"NSObject" record:record];
        
        code = [NSString stringWithFormat:@"[GlobalMethod getOverlayRGBA:%@ frame:CGRectMake(0, 0, %.1f, %.1f)",
                [self colorStringWithRGBA:record.bgColor.effect.rgba],
                ceil(overlay.frame.size.width), ceil(overlay.frame.size.height)];
        
        if (overlayer) {
            *overlayer = overlay;
        }
    }
    return code;
}

+ (NSString *)addEffectStoke:(CALayer *)contentLayer record:(YLPSDLayerRecordInfo *)record viewName:(NSString *)viewName {
    NSString *code = @"";
    if (record.bgColor.effect.frfx) {
        YLEffectStroke *frfx = record.bgColor.effect.frfx;
        UIColor *rgba = [YLRGBA colorWithRGBA:frfx.rgba];
        if (frfx.overprint) {
            rgba = [YLRGBA colorWithRGBA:record.bgColor.stoke.rgba overlay:frfx.rgba];
        }
        YLRGBA *stokeColor = [YLRGBA rgbaColorFromUIColor:rgba];
        if (frfx.sz > 0) {
            if ([contentLayer isKindOfClass:[CAShapeLayer class]]) {
                CAShapeLayer *shapeLayer = (CAShapeLayer *)contentLayer;
                if ([frfx.styl isEqualToString:@"InsF"]) {
                    shapeLayer.strokeColor = rgba.CGColor;
                    shapeLayer.lineWidth = frfx.sz;
                } else if ([frfx.styl isEqualToString:@"OutF"]) {
                    shapeLayer.strokeColor = rgba.CGColor;
                    shapeLayer.lineWidth = frfx.sz;
                }
                code = [code stringByAppendingFormat:@"%@.strokeColor = [UIColor colorWithRed:153/255.0 green:%d/255.0 blue:%d/255.0 alpha:%d/255.0].CGColor;\n%@.lineWidth = %.1f;\n",viewName,stokeColor.red,stokeColor.green,stokeColor.blue,viewName,frfx.sz];
            } else {
                if ([frfx.styl isEqualToString:@"InsF"]) {
                    contentLayer.borderColor = rgba.CGColor;
                    contentLayer.borderWidth = frfx.sz;
                } else if ([frfx.styl isEqualToString:@"OutF"]) {
                    contentLayer.borderColor = rgba.CGColor;
                    contentLayer.borderWidth = frfx.sz;
                }
                code = [code stringByAppendingFormat:@"%@.borderColor = %@.CGColor;\n%@.borderWidth = %.1f;\n",viewName,[self colorStringWithRGBA:stokeColor],viewName,frfx.sz];
            }
        }
    }
    return code;
}


+ (NSArray<NSValue *> *)getPoint:(CGFloat)angl {
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;

    CGPoint intersect1 = CGPointZero;
    CGPoint intersect2 = CGPointZero;
    
    CGFloat k = 1;
    if (sin(angl) == 1) {
       startPoint = CGPointMake(0.5, 1);
       endPoint = CGPointMake(0.5, 0);
    } else if (sin(angl) == -1) {
       startPoint = CGPointMake(0.5, 0);
       endPoint = CGPointMake(0.5, 1);
    } else {
       k = tan(angl);
       CGFloat y = k * 0.5;
       if (fabs(y) <= 0.5) {
           intersect1 = CGPointMake((0.5 + 0.5), (0.5 - y));
           intersect2 = CGPointMake((0.5 - 0.5), (0.5 - (k * (-0.5))));
       } else {
           CGFloat x = k / 0.5;
           intersect1 = CGPointMake((0.5 + x), (0.5 - 0.5));
           intersect2 = CGPointMake((0.5 - x), (0.5 + 0.5));
       }
       if (sin(angl) >= 0) {
           if (intersect1.y > intersect2.y) {
               startPoint = intersect1;
               endPoint = intersect2;
           } else {
               startPoint = intersect2;
               endPoint = intersect1;
           }
       } else {
           if (intersect1.y > intersect2.y) {
               startPoint = intersect2;
               endPoint = intersect1;
           } else {
               startPoint = intersect1;
               endPoint = intersect2;
           }
       }
    }
    
    return [NSArray arrayWithObjects:[NSValue valueWithCGPoint:startPoint],[NSValue valueWithCGPoint:endPoint], nil];
}

@end
