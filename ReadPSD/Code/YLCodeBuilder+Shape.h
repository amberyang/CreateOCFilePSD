//
//  YLCodeBuilder+Shape.h
//  ReadPSD
//
//  Created by amber on 2020/6/11.
//  Copyright © 2020 amber. All rights reserved.
//


#import "YLCodeBuilder.h"

@interface YLCodeBuilder (Shape)

+ (CAShapeLayer *)getShapeLayer:(UIView *)originView refer:(UIView *)pathView
                         points:(NSArray *)value frame:(CGRect)frame
                      fillColor:(UIColor *)fillColor stokeColor:(UIColor *)stokeColor
                         record:(YLPSDLayerRecordInfo *)record;

+ (CGPoint)postionInView:(UIView *)superView refer:(UIView *)referView point:(CGPoint)point;

@end
