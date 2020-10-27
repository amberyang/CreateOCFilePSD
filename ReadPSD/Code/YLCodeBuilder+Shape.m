//
//  YLCodeBuilder+Shape.m
//  ReadPSD
//
//  Created by amber on 2020/6/11.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLCodeBuilder+Shape.h"
#import "YLMethodManager.h"

@implementation YLCodeBuilder (Shape)

+ (CAShapeLayer *)getShapeLayer:(UIView *)originView refer:(UIView *)pathView
                         points:(NSArray *)value frame:(CGRect)frame
                      fillColor:(UIColor *)fillColor stokeColor:(UIColor *)stokeColor
                         record:(YLPSDLayerRecordInfo *)record {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFrame:frame];
    NSString *pathCode = [NSString stringWithFormat:@"CAShapeLayer *shapeLayer = [CAShapeLayer layer];\n"
                          "[shapeLayer setFrame:frame];\n"];
    
    UIBezierPath *resultPath = [UIBezierPath bezierPath];
    pathCode = [pathCode stringByAppendingString:@"UIBezierPath *resultPath = [UIBezierPath bezierPath];\n"];
    
    for (NSInteger i=0; i<value.count; i++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        NSDictionary *shape = [value objectAtIndex:i];
        NSArray *points = [shape objectForKey:@"points"];
        NSString *precedingKey = @"preceding";
        NSString *leavingKey = @"leaving";
        for (NSInteger j=0; j<points.count; j++) {
//            NSInteger type = [[[points objectAtIndex:j] objectForKey:@"type"] integerValue];
            CGPoint anchor = [[[points objectAtIndex:j] objectForKey:@"anchor"] CGPointValue];
            CGPoint current = [[self class] postionInView:originView refer:pathView point:anchor];
            if (j == 0) {
                [path moveToPoint:current];
            } else {
                CGPoint preceding = [[[points objectAtIndex:j] objectForKey:precedingKey] CGPointValue];
                CGPoint precede = [[self class] postionInView:originView refer:pathView point:preceding];
                CGPoint leaving = [[[points objectAtIndex:j-1] objectForKey:leavingKey] CGPointValue];
                CGPoint leave = [[self class] postionInView:originView refer:pathView point:leaving];
                [path addCurveToPoint:current controlPoint1:leave controlPoint2:precede];
                if (j == points.count-1) {
//                    type = [[[points objectAtIndex:0] objectForKey:@"type"] integerValue];
                    anchor = [[[points objectAtIndex:0] objectForKey:@"anchor"] CGPointValue];
                    current = [[self class] postionInView:originView refer:pathView point:anchor];
                    preceding = [[[points objectAtIndex:0] objectForKey:precedingKey] CGPointValue];
                    precede = [[self class] postionInView:originView refer:pathView point:preceding];
                    leaving = [[[points objectAtIndex:(points.count-1)] objectForKey:leavingKey] CGPointValue];
                    leave = [[self class] postionInView:originView refer:pathView point:leaving];
                    [path addCurveToPoint:current controlPoint1:leave controlPoint2:precede];
                }
            }
        }
        
        
        [path closePath];
        [resultPath appendPath:path];
//        pathCode = [pathCode stringByAppendingString:@"[path closePath];\n[resultPath appendPath:path];\n"];

    }
    
    NSString *drawCode = @"for (NSInteger i=0; i<value.count; i++) {\n"
        "UIBezierPath *path = [UIBezierPath bezierPath];\n"
        "NSDictionary *shape = [value objectAtIndex:i];\n"
        "NSArray *points = [shape objectForKey:@\"points\"];\n"
        "NSString *precedingKey = @\"preceding\";\n"
        "NSString *leavingKey = @\"leaving\";\n"
        "for (NSInteger j=0; j<points.count; j++) {\n"
            "NSInteger type = [[[points objectAtIndex:j] objectForKey:@\"type\"] integerValue];\n"
            "CGPoint anchor = [[[points objectAtIndex:j] objectForKey:@\"anchor\"] CGPointValue];\n"
            "CGPoint current = [[self class] postionInView:originView refer:pathView point:anchor];\n"
            "if (j == 0) {\n"
                "[path moveToPoint:current];\n"
            "} else {\n"
                "CGPoint preceding = [[[points objectAtIndex:j] objectForKey:precedingKey] CGPointValue];\n"
                "CGPoint precede = [[self class] postionInView:originView refer:pathView point:preceding];\n"
                "CGPoint leaving = [[[points objectAtIndex:j-1] objectForKey:leavingKey] CGPointValue];\n"
                "CGPoint leave = [[self class] postionInView:originView refer:pathView point:leaving];\n"
                "[path addCurveToPoint:current controlPoint1:leave controlPoint2:precede];\n"
                "if (j == points.count-1) {\n"
                    "type = [[[points objectAtIndex:0] objectForKey:@\"type\"] integerValue];\n"
                    "anchor = [[[points objectAtIndex:0] objectForKey:@\"anchor\"] CGPointValue];\n"
                    "current = [[self class] postionInView:originView refer:pathView point:anchor];\n"
                    "preceding = [[[points objectAtIndex:0] objectForKey:precedingKey] CGPointValue];\n"
                    "precede = [[self class] postionInView:originView refer:pathView point:preceding];\n"
                    "leaving = [[[points objectAtIndex:(points.count-1)] objectForKey:leavingKey] CGPointValue];\n"
                    "leave = [[self class] postionInView:originView refer:pathView point:leaving];\n"
                    "[path addCurveToPoint:current controlPoint1:leave controlPoint2:precede];\n"
                "}\n"
           "}\n"
        "}\n"
        "[path closePath];\n"
        "[resultPath appendPath:path];\n"
    "}\n";
    
    pathCode = [pathCode stringByAppendingString:drawCode];
    
    shapeLayer.path = resultPath.CGPath;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.strokeColor = fillColor.CGColor;
    shapeLayer.fillColor = stokeColor.CGColor;

    pathCode = [pathCode stringByAppendingString:@"shapeLayer.path = resultPath.CGPath;\n"
                "shapeLayer.fillRule = kCAFillRuleEvenOdd;\n"
                "shapeLayer.lineCap = kCALineCapButt;\n"
                "shapeLayer.strokeColor = fillColor.CGColor;\n"
                "shapeLayer.fillColor = stokeColor.CGColor;\n"
                "return shapeLayer;\n"];
    
    [[YLMethodManager shareInstance] insertGlobalMethod:@"+ (CAShapeLayer *)getShapeLayer:(NSArray *)value fillColor:(UIColor *)fillColor stokeColor:(UIColor *)stokeColor frame:(CGRect)frame" content:pathCode viewClass:@"GlobalMethod" superClass:@"NSObject" record:record];
    
    return shapeLayer;
}

+ (CGPoint)postionInView:(UIView *)superView refer:(UIView *)referView point:(CGPoint)point {
    CGPoint originPoint = CGPointMake(point.x * CGRectGetWidth(superView.frame), point.y * CGRectGetHeight(superView.frame));
    CGPoint realPoint = [superView convertPoint:originPoint toView:referView];
    return realPoint;
}

@end
