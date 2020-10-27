//
//  YLCodeBuilder.h
//  ReadPSD
//
//  Created by amber on 2020/6/4.
//  Copyright © 2020 amber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLPSDLayerRecordInfo.h"


@interface YLCodeBuilder : NSObject

+ (NSString *)generateView:(YLPSDLayerRecordInfo *)record view:(UIView **)aView
                     frame:(CGRect)layerFrame superView:(UIView *)superView rate:(CGFloat)rate;

+ (NSString *)generateLabel:(YLPSDLayerRecordInfo *)record label:(UILabel **)aLabel
                      frame:(CGRect)layerFrame superView:(UIView *)superView rate:(CGFloat)rate;

+ (NSString *)generateImageView:(YLPSDLayerRecordInfo *)record
                      imageView:(UIImageView **)aImageView frame:(CGRect)layerFrame
                      superView:(UIView *)superView rate:(CGFloat)rate;

+ (NSString *)generateGradientView:(YLPSDLayerRecordInfo *)record view:(UIView **)aView
                     gradientLayer:(CAGradientLayer **)gradientLayer frame:(CGRect)layerFrame
                         superView:(UIView *)superView rate:(CGFloat)rate;

+ (NSString *)generateShapeView:(YLPSDLayerRecordInfo *)record view:(UIView **)aView
                      pathLayer:(CAShapeLayer **)pathLayer frame:(CGRect)layerFrame
                           mask:(UIView *)mask
                     originView:(UIView *)originView superView:(UIView *)superView rate:(CGFloat)rate;

+ (NSString *)replaceSpecialWord:(NSString *)string;

+ (NSString *)colorStringWithRGBA:(YLRGBA *)rgba;

+ (NSString *)setFrame:(NSString *)viewName frame:(CGRect)frame superFrame:(CGRect)superFrame;

@end

