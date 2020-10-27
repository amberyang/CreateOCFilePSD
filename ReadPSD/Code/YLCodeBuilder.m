//
//  YLCodeBuilder.m
//  ReadPSD
//
//  Created by amber on 2020/6/4.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLCodeBuilder.h"
#import "YLMethodManager.h"
#import "YLTextInfo.h"
#import "UIImage+Overlay.h"
#import "YLCodeBuilder+Effect.h"
#import "YLCodeBuilder+OriginEffect.h"
#import "YLCodeBuilder+Shape.h"
#import "GloableHeader.h"

@implementation YLCodeBuilder

+ (NSString *)generateView:(YLPSDLayerRecordInfo *)record view:(UIView **)aView
                     frame:(CGRect)layerFrame superView:(UIView *)superView rate:(CGFloat)rate {
    UIView *bgView = [[UIView alloc] initWithFrame:layerFrame];
    [bgView setBackgroundColor:[UIColor clearColor]];
    bgView.alpha = record.opacity/255.0;
    bgView.clipsToBounds = YES;
    if (aView) {
        *aView = bgView;
    }
    NSString *path = @"";
    NSString *name = [[self class] replaceSpecialWord:record.name.text];

    if (record.records.count > 0) {
        YLPSDLayerRecordInfo *parentRecord = record.parentRecord;
        while (parentRecord) {
            NSString *parentName = [[self class] replaceSpecialWord:parentRecord.name.text];
            path = [parentName stringByAppendingPathComponent:path];
            parentRecord = parentRecord.parentRecord;
        }
        NSLog(@"file path: %@", path);
        [[YLMethodManager shareInstance] insertPath:path forClass:name];
    }
    
    NSString *viewName = name;
    
    NSString *viewAlpha = [[self class] setAlpha:record layer:bgView.layer name:[NSString stringWithFormat:@"_%@.layer",viewName]];
    NSString *code = [NSString stringWithFormat:@"if (!_%@) {\n"
                      "_%@ = [[%@ alloc] init];\n"
                      "%@"
                      "_%@.clipsToBounds = YES;\n"
                      "}\n"
                      "return _%@;\n", viewName, viewName, viewName.capitalizedString, viewAlpha, viewName, viewName];
    
    NSString *valueCode = [NSString stringWithFormat:@"[self addSubview:self.%@];\n",viewName];
    CAGradientLayer *gradientLayer;
    NSString *gradientName = [NSString stringWithFormat:@"%@_overGrad",viewName];
    valueCode = [valueCode stringByAppendingString:[[self class] addEffectGradient:bgView.layer gradient:&gradientLayer record:record mixColor:nil viewName:gradientName]];
    if (gradientLayer) {
        [bgView.layer addSublayer:gradientLayer];
        valueCode = [valueCode stringByAppendingFormat:@"[self.%@.layer addSublayer:%@];\n",viewName,gradientName];
    }
    
    valueCode = [valueCode stringByAppendingString:[[self class] addEffectStoke:bgView.layer record:record viewName:[NSString stringWithFormat:@"self.%@.layer",viewName]]];
      
    NSString *calSize = [NSString stringWithFormat:@"CGSize %@_size = [_%@ sizeThatFits:CGSizeMake(%.1f, CGFLOAT_MAX)];\n",viewName,viewName,CGRectGetWidth(layerFrame)];
    NSString *layout = [NSString stringWithFormat:@"CGSize %@_size = [_%@ sizeThatFits:CGSizeMake(%.1f, CGFLOAT_MAX)];\n",viewName,viewName,CGRectGetWidth(layerFrame)];
    NSString *viewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",viewName] frame:layerFrame superFrame:superView.frame];
    layout = [layout stringByAppendingString:viewFrame];
    
    record.classView = bgView;
    
    [[YLMethodManager shareInstance] insertProperty:record viewClass:viewName.capitalizedString superClass:@"UIView" value:valueCode layout:layout initial:code calculateSize:calSize];
    
    BOOL superChanged = [[self class] adjustSuperFrame:superView contentView:bgView];
    if (superChanged) {
        YLPSDLayerRecordInfo *parent = record.parentRecord;
        NSString *parentViewName = [[self class] replaceSpecialWord:parent.name.text];
        NSString *parentViewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",parentViewName] frame:superView.frame superFrame:superView.superview.frame];
        
        [[YLMethodManager shareInstance] updateProperty:parent layout:parentViewFrame];
    }
    
    return code;
}

+ (NSString *)generateLabel:(YLPSDLayerRecordInfo *)record label:(UILabel **)aLabel
                      frame:(CGRect)layerFrame superView:(UIView *)superView rate:(CGFloat)rate {
    NSInteger overlayRGBAIndex = 0;
    YLRGBA *overlayRGBA = [record getOverlayRGBA:&overlayRGBAIndex];
        
    UILabel *label = nil;
    NSString *viewName = [[self class] replaceSpecialWord:record.name.text];
    
    NSString *viewAlpha = [[self class] setAlpha:record layer:label.layer name:[NSString stringWithFormat:@"_%@.layer",viewName]];
    NSString *code = [NSString stringWithFormat:@"if (!_%@) {\n"
                      "_%@ = [[UILabel alloc] init];\n"
                      "%@",viewName,viewName,viewAlpha];
    
    NSString *valueCode = [NSString stringWithFormat:@"[self addSubview:self.%@];\n",viewName];
    NSString *layoutCode = @"";
    NSString *calSizeStr = @"";
    
    if ([record.adjustments.allKeys containsObject:@"tysh"]) {
        YLPSDAdditionalLayerInfo *addtional = [record.adjustments objectForKey:@"tysh"];
        NSArray *value = [[[addtional.result objectForKey:@"tysh"] objectForKey:@"result"] objectForKey:@"txlr"];
        if (!value) {
            value = [[[addtional.result objectForKey:@"tysh"] objectForKey:@"result"] allValues][0];
        }
        if (value.count > 0) {
            label = [[UILabel alloc] initWithFrame:layerFrame];
            for (NSDictionary *dic in value) {
                NSDictionary *param = [dic objectForKey:@"enginedata"];
                YLTextInfo *textInfo = [param objectForKey:@"tdta"];
                if (textInfo) {
                    NSString *transText = [textInfo.text stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
                    transText = [transText stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                    [label setText:textInfo.text];
                    valueCode = [valueCode stringByAppendingFormat:@"[self.%@ setText:@\"%@\"];\n",viewName,transText];
                    
                    NSArray<YLTextInfo *> *alignArray = [textInfo.styles objectForKey:@"text_align"];

                    NSString *align = @"NSTextAlignmentLeft";
                    if (alignArray.count > 0) {
                        YLTextInfo *alignInfo = [alignArray objectAtIndex:0];
                        if (alignInfo.alignment == 2) {
                            [label setTextAlignment:NSTextAlignmentCenter];
                            align = YL_ENUM_String(NSTextAlignmentCenter);
                        } else if (alignInfo.alignment == 3) {

                        } else if (alignInfo.alignment == 1) {
                            [label setTextAlignment:NSTextAlignmentRight];
                            align = YL_ENUM_String(NSTextAlignmentRight);
                        } else if (alignInfo.alignment == 0) {
                            [label setTextAlignment:NSTextAlignmentLeft];
                        }
                    } else {
                        [label setTextAlignment:NSTextAlignmentLeft];
                    }
                    code = [code stringByAppendingFormat:@"[_%@ setTextAlignment:%@];\n",viewName,align];
                    
                    NSArray<YLTextInfo *> *styleArray = [YLTextInfo mergeAttr:[textInfo.styles objectForKey:@"text_info"]];
                    if (styleArray.count > 1 || (textInfo.leading > 0 && [textInfo.text containsString:@"\r"])) {
                        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:textInfo.text];
                        valueCode = [valueCode stringByAppendingFormat:@"NSMutableAttributedString *%@_attr = [[NSMutableAttributedString alloc] initWithString:@\"%@\"];\n", viewName,transText];
                        if ((textInfo.leading > 0 && [textInfo.text containsString:@"\r"])) {
                            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                            [paragraphStyle setLineSpacing:textInfo.leading];
                            [paragraphStyle setAlignment:label.textAlignment];
                            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textInfo.text length])];
                            valueCode = [valueCode stringByAppendingFormat:@"NSMutableParagraphStyle *%@_paragraphStyle = [[NSMutableParagraphStyle alloc] init];\n"
                                         "[%@_paragraphStyle setLineSpacing:%.1f];\n"
                                         "[%@_paragraphStyle setAlignment:%@];\n"
                                         "[%@_attr addAttribute:NSParagraphStyleAttributeName value:%@_paragraphStyle range:NSMakeRange(0, %ld)];\n",viewName,viewName,textInfo.leading*rate,viewName,align,viewName,viewName,textInfo.text.length];
                        }

                        BOOL autoKerning = NO;
                        for (YLTextInfo *styleInfo in styleArray) {
                            UIFont *font = nil;
                            NSString *fontString = @"";
                            CGFloat fontSize = ceil(styleInfo.fontSize * rate);
                            if (styleInfo.isBold) {
                                font = [UIFont boldSystemFontOfSize:fontSize];
                                fontString = [NSString stringWithFormat:@"[UIFont boldSystemFontOfSize:ceil(%.1f)]",fontSize];
                            } else {
                                font = [UIFont systemFontOfSize:fontSize];
                                fontString = [NSString stringWithFormat:@"[UIFont systemFontOfSize:ceil(%.1f)]",fontSize];
                            }
                            if (styleInfo.autoKerning) {
                                autoKerning = YES;
                                label.adjustsFontSizeToFitWidth = YES;
                            }
                            NSInteger length = MIN(styleInfo.textLength, textInfo.text.length-styleInfo.startIndex);
                            if (length > 0 && styleInfo.startIndex < textInfo.text.length) {
                                [attr addAttribute:NSFontAttributeName value:font range:NSMakeRange(styleInfo.startIndex, length)];
                                UIColor *textColor = [YLRGBA colorWithRGBA:styleInfo.fillColor overlay:overlayRGBA];
                                [attr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(styleInfo.startIndex, length)];
                                
                                YLRGBA *textColorRGBA = [YLRGBA rgbaColorFromUIColor:textColor];
                                valueCode = [valueCode stringByAppendingFormat:@"[%@_attr addAttribute:NSFontAttributeName value:%@ range:NSMakeRange(%ld, %ld)];\n",viewName,fontString,styleInfo.startIndex,length];
                                valueCode = [valueCode stringByAppendingFormat:@"[%@_attr addAttribute:NSForegroundColorAttributeName value:%@ range:NSMakeRange(%ld, %ld)];\n",viewName,[self colorStringWithRGBA:textColorRGBA],styleInfo.startIndex,length];
                            }
                        }
                        [label setAttributedText:attr];
                        valueCode = [valueCode stringByAppendingFormat:@"[self.%@ setAttributedText:%@_attr];\n",viewName,viewName];
                        code = autoKerning?[code stringByAppendingFormat:@"_%@.adjustsFontSizeToFitWidth = YES;\n",viewName]:@"";
                    } else if (styleArray.count == 1) {
                        YLTextInfo *styleInfo = [styleArray objectAtIndex:0];
                        UIColor *textColor = [YLRGBA colorWithRGBA:styleInfo.fillColor overlay:overlayRGBA];
                        YLRGBA *textRGBA = [YLRGBA rgbaColorFromUIColor:textColor];
                        [label setTextColor:textColor];
                        code = [code stringByAppendingFormat:@"[_%@ setTextColor:%@];\n",viewName,[self colorStringWithRGBA:textRGBA]];
                        CGFloat fontSize = ceil(styleInfo.fontSize * rate);
                        if (styleInfo.isBold) {
                            [label setFont:[UIFont boldSystemFontOfSize:fontSize]];
                            code = [code stringByAppendingFormat:@"[_%@ setFont:[UIFont boldSystemFontOfSize:ceil(%.1f)]];\n",viewName,fontSize];
                        } else {
                            [label setFont:[UIFont systemFontOfSize:fontSize]];
                            code = [code stringByAppendingFormat:@"[_%@ setFont:[UIFont systemFontOfSize:ceil(%.1f)]];\n",viewName,fontSize];
                        }
                        if (styleInfo.autoKerning) {
                            label.adjustsFontSizeToFitWidth = YES;
                            code = [code stringByAppendingFormat:@"_%@.adjustsFontSizeToFitWidth = YES;\n",viewName];
                        }
                    } else {
                        NSLog(@"not found text style infomation");
                    }
                    
                    CGRect frame = label.frame;
                    
                    if ([textInfo.text containsString:@"\r"]) {
                        [label setLineBreakMode:NSLineBreakByCharWrapping];
                        [label setNumberOfLines:0];
                        CGSize size = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                        frame.size = CGSizeMake(ceil(size.width), ceil(size.height));
                        code = [code stringByAppendingFormat:@"[_%@ setLineBreakMode:NSLineBreakByCharWrapping];\n"
                                "[_%@ setNumberOfLines:0];\n",viewName,viewName];
                    } else {
                        CGSize size = [label sizeThatFits:CGSizeMake((record.layerInsets.right-record.layerInsets.left)*rate, CGFLOAT_MAX)];
                        frame.size = CGSizeMake(ceil(size.width), ceil(size.height));
                    }
                    
                    if (alignArray.count > 0) {
                        YLTextInfo *alignInfo = [alignArray objectAtIndex:0];
                        if (alignInfo.alignment == 2) {
                            frame.origin.x = (CGRectGetWidth(layerFrame) - frame.size.width)/2 + CGRectGetMinX(layerFrame);
                        } else if (alignInfo.alignment == 3) {

                        } else if (alignInfo.alignment == 1) {
                            frame.origin.x = CGRectGetMaxX(layerFrame) - frame.size.width;
                        } else if (alignInfo.alignment == 0) {
                        }
                    } else {
                    }

                    frame.origin.y = CGRectGetMinY(frame)-(CGRectGetHeight(frame)-CGRectGetHeight(layerFrame))/2;
                    
                    label.frame = frame;
                    
                    NSString *calSize = [NSString stringWithFormat:@"CGSize %@_size = [_%@ sizeThatFits:CGSizeMake(%.1f, CGFLOAT_MAX)];\n",viewName,viewName,CGRectGetWidth(frame)];
                    calSizeStr = [NSString stringWithFormat:@"CGSize %@_size = [_%@ sizeThatFits:CGSizeMake(%.1f, CGFLOAT_MAX)];\n",viewName,viewName,CGRectGetWidth(frame)];
                    NSString *viewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",viewName] frame:label.frame superFrame:superView.frame];

                    if (label.adjustsFontSizeToFitWidth) {
                        CGFloat frameRate = layerFrame.size.width/frame.size.width;
                        label.transform = CGAffineTransformScale(CGAffineTransformIdentity, frameRate, frameRate);
                        label.frame = CGRectMake(CGRectGetMinX(layerFrame)-(CGRectGetWidth(label.frame)-CGRectGetWidth(layerFrame))/2, CGRectGetMinY(layerFrame)-(CGRectGetHeight(label.frame)-CGRectGetHeight(layerFrame))/2, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
                        
                        viewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",viewName] frame:label.frame superFrame:superView.frame];
                        if (![@"1.0" isEqualToString:[NSString stringWithFormat:@"%.1f",frameRate]]) {
//                            layoutCode = [layoutCode stringByAppendingFormat:@"_%@.transform = CGAffineTransformScale(CGAffineTransformIdentity, %.1f, %.1f);\n"
//                                          "%@"
//                                          "%@",viewName,frameRate,frameRate,calSize,viewFrame];
                        }
                        layoutCode = [layoutCode stringByAppendingFormat:@"%@%@",calSize,viewFrame];
                    } else {
                        layoutCode = [layoutCode stringByAppendingFormat:@"%@%@",calSize,viewFrame];
                    }
                    
                    NSNumber *angle = [[addtional.result objectForKey:@"tysh"] objectForKey:@"trans_angl"];
                    if (angle && [angle doubleValue] != 0) {
                        CATransform3D transfrom = CATransform3DMakeRotation([angle floatValue], 0, 0, 1);
                        transfrom = CATransform3DRotate(transfrom, 0, 1.0f, 0.0f, 0.0f);
                        label.layer.transform = transfrom;
                        if (![@"1.00" isEqualToString:[NSString stringWithFormat:@"%.2f",[angle floatValue]]]) {
                            layoutCode = [layoutCode stringByAppendingFormat:@"CATransform3D %@_transfrom = CATransform3DMakeRotation(%.2f, 0, 0, 1);\n"
                                    "%@_transfrom = CATransform3DRotate(%@_transfrom, 0, 1.0f, 0.0f, 0.0f);\n"
                                    "_%@.layer.transform = %@_transfrom;\n",viewName,[angle floatValue],viewName,viewName,viewName,viewName];
                        }
                    }
                }
            }
        }
    }
    
    CAGradientLayer *gradientLayer;
    YLRGBA *textColor = [YLRGBA rgbaColorFromUIColor:label.textColor];
    NSString *gradientName = [NSString stringWithFormat:@"%@_overGrad",viewName];
    valueCode = [valueCode stringByAppendingString:[[self class] addEffectGradient:label.layer gradient:&gradientLayer record:record mixColor:textColor viewName:gradientName]];
    if (gradientLayer) {
        label.layer.mask = gradientLayer;
        valueCode = [valueCode stringByAppendingFormat:@"self.%@.layer.mask = %@;\n",viewName,gradientName];
    }
    
    valueCode = [valueCode stringByAppendingString:[[self class] addEffectStoke:label.layer record:record viewName:[NSString stringWithFormat:@"self.%@.layer",viewName]]];
    
    code = [code stringByAppendingFormat:@"}\nreturn _%@;\n",viewName];

    if (label) {
        if (aLabel) {
            *aLabel = label;
        }
        
        record.classView = label;
        [[YLMethodManager shareInstance] insertProperty:record viewClass:nil superClass:@"UILabel"  value:valueCode layout:layoutCode initial:code calculateSize:calSizeStr];
        
        BOOL superChanged = [[self class] adjustSuperFrame:superView contentView:label];
        if (superChanged) {
            YLPSDLayerRecordInfo *parent = record.parentRecord;
            NSString *parentViewName = [[self class] replaceSpecialWord:parent.name.text];
            NSString *parentViewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",parentViewName] frame:superView.frame superFrame:superView.frame];
            
            [[YLMethodManager shareInstance] updateProperty:parent layout:parentViewFrame];
        }
    }
    return code;
}

+ (NSString *)generateImageView:(YLPSDLayerRecordInfo *)record
                      imageView:(UIImageView **)aImageView frame:(CGRect)layerFrame
                      superView:(UIView *)superView rate:(CGFloat)rate {
    
    UIImage *image = record.image;
    
    NSInteger overlayRGBAIndex = 0;
    YLRGBA *overlayRGBA = [record getOverlayRGBA:&overlayRGBAIndex];
    
    if (overlayRGBAIndex > 0) {
        image = [image imageWithGradientTintColor:[YLRGBA colorWithRGBA:overlayRGBA]];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:layerFrame];
    
    NSString *viewName = [[self class] replaceSpecialWord:record.name.text];
    
    NSString *viewAlpha = [[self class] setAlpha:record layer:imageView.layer name:[NSString stringWithFormat:@"_%@.layer",viewName]];
    NSString *code = [NSString stringWithFormat:@"if (!_%@) {\n"
                      "_%@ = [[UIImageView alloc] init];\n"
                      "[_%@ setContentMode:UIViewContentModeScaleAspectFit];\n"
                      "%@",viewName,viewName,viewName,viewAlpha];
    
    NSString *valueCode = [NSString stringWithFormat:@"[self addSubview:self.%@];\nUIImage *%@_image = [UIImage imageNamed:@\"%@.png\"];\n"
                           "self.%@.image = %@_image;\n",viewName,viewName,viewName,viewName,viewName];
    CAGradientLayer *gradientLayer;
    NSString *gradientName = [NSString stringWithFormat:@"%@_overGrad",viewName];
    valueCode = [valueCode stringByAppendingString:[[self class] addEffectGradient:imageView.layer gradient:&gradientLayer record:record mixColor:nil viewName:gradientName]];
    if (gradientLayer) {
        imageView.layer.mask = gradientLayer;
        valueCode = [valueCode stringByAppendingFormat:@"self.%@.layer.mask = %@;\n",viewName,gradientName];
    }
    
    if (aImageView) {
        *aImageView = imageView;
    }
    
    code = [code stringByAppendingFormat:@"}\nreturn _%@;\n",viewName];

    NSString *viewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",viewName] frame:imageView.frame superFrame:superView.frame];
        
    record.classView = imageView;
    [[YLMethodManager shareInstance] insertProperty:record viewClass:nil superClass:@"UIImageView" value:valueCode layout:viewFrame initial:code calculateSize:[NSString stringWithFormat:@"%.1f",CGRectGetHeight(layerFrame)]];
    
    [[YLMethodManager shareInstance] insertImage:image imageName:[NSString stringWithFormat:@"%@.png",viewName] record:record];
    
    BOOL superChanged = [[self class] adjustSuperFrame:superView contentView:imageView];
    if (superChanged) {
        YLPSDLayerRecordInfo *parent = record.parentRecord;
        NSString *parentViewName = [[self class] replaceSpecialWord:parent.name.text];
        NSString *parentViewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",parentViewName] frame:superView.frame superFrame:superView.frame];
        
        [[YLMethodManager shareInstance] updateProperty:parent layout:parentViewFrame];
    }
    
    return code;
}

+ (NSString *)generateGradientView:(YLPSDLayerRecordInfo *)record view:(UIView **)aView gradientLayer:(CAGradientLayer **)gradientLayer frame:(CGRect)layerFrame superView:(UIView *)superView rate:(CGFloat)rate {
    UIView *bgView = [[UIView alloc] initWithFrame:layerFrame];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, CGRectGetWidth(bgView.frame), CGRectGetHeight(bgView.frame));
    
    CGFloat angl = record.bgColor.gradient.angl/180.0*M_PI;
    if (record.bgColor.gradient.rvrs) {
        angl = (record.bgColor.gradient.angl+180.0)/180.0*M_PI;
    }
    NSArray<NSValue *> *points = [[self class] getPoint:angl];

    gradient.startPoint = [[points objectAtIndex:0] CGPointValue];
    gradient.endPoint = [[points objectAtIndex:1] CGPointValue];
    
    NSString *locasString = @"[NSArray arrayWithObjects:";
    NSString *colorsString = @"[NSArray arrayWithObjects:";

    NSMutableArray *locas = [NSMutableArray array];
    NSMutableArray *colors = [NSMutableArray array];
    for (YLRGBAGradient *rgba in record.bgColor.gradient.gradients) {
        UIColor *color = [YLRGBA colorWithRGBA:rgba];
        [colors addObject:(id)color.CGColor];
        [locas addObject:@(rgba.position)];
        
        locasString = [locasString stringByAppendingFormat:@"%.1f,",rgba.position];
        colorsString = [colorsString stringByAppendingFormat:@"(id)%@.CGColor",[self colorStringWithRGBA:rgba]];
    }
    gradient.colors = colors;
    gradient.locations = locas;
    
    locasString = [locasString stringByAppendingString:@"nil];\n"];
    colorsString = [colorsString stringByAppendingString:@"nil];\n"];
    
    if (record.bgColor.circular) {
        gradient.cornerRadius = [record.bgColor.circular cornerRadius];
    }
    [bgView.layer addSublayer:gradient];
    
    if (gradientLayer) {
        *gradientLayer = gradient;
    }
    
    NSString *stokeCode = [[self class] addStoke:record layer:gradient name:@"gradient"];

    CALayer *overlay;
    NSString *overlayCode = [[self class] addEffectOverlayRGBA:gradient overlayer:&overlay record:record];
    [gradient addSublayer:overlay];
    
    NSString *viewName = [[self class] replaceSpecialWord:record.name.text];
    
    NSString *gradientCode = [NSString stringWithFormat:@"CAGradientLayer *gradient = [CAGradientLayer layer];\n"
                              "gradient.frame = _%@.bounds"
                              "gradient.startPoint = CGPointMake(%.1f, %.1f);\n"
                              "gradient.endPoint = CGPointMake(%.1f, %.1f);\n"
                              "gradient.colors = %@;\n"
                              "gradient.locasString = %@;\n"
                              "%@"
                              "[self.%@.layer addSublayer:gradient];\n",
                              viewName,gradient.startPoint.x, gradient.startPoint.y, gradient.endPoint.x,
                              gradient.endPoint.y,colorsString,locasString,stokeCode,viewName];
    
    NSString *viewAlpha = [[self class] setAlpha:record layer:bgView.layer name:[NSString stringWithFormat:@"_%@.layer",viewName]];
    NSString *code = [NSString stringWithFormat:@"if (!_%@) {\n"
                      "_%@ = [[UIView alloc] init];\n"
                      "%@", viewName, viewName, viewAlpha];
    
    NSString *valueCode = [NSString stringWithFormat:@"%@%@",gradientCode,overlayCode];

    CAGradientLayer *effectGradient;
    NSString *gradientName = [NSString stringWithFormat:@"%@_overGrad",viewName];
    code = [code stringByAppendingString:[[self class] addEffectGradient:gradient gradient:&effectGradient record:record mixColor:nil viewName:gradientName]];
    if (effectGradient) {
        [bgView.layer addSublayer:effectGradient];
        valueCode = [code stringByAppendingFormat:@"[self.%@.layer addSublayer:%@];\n",viewName,gradientName];
    }
    
    valueCode = [valueCode stringByAppendingString:[[self class] addEffectStoke:bgView.layer record:record viewName:[NSString stringWithFormat:@"self.%@.layer",viewName]]];
    
    code = [code stringByAppendingFormat:@"}\nreturn _%@;\n",viewName];

    NSString *viewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",viewName] frame:layerFrame superFrame:superView.frame];
    
    record.classView = bgView;
    [[YLMethodManager shareInstance] insertProperty:record viewClass:nil superClass:@"UIView" value:valueCode layout:viewFrame initial:code calculateSize:[NSString stringWithFormat:@"%.1f",CGRectGetHeight(layerFrame)]];
    
    BOOL superChanged = [[self class] adjustSuperFrame:superView contentView:bgView];
    if (superChanged) {
        YLPSDLayerRecordInfo *parent = record.parentRecord;
        NSString *parentViewName = [[self class] replaceSpecialWord:parent.name.text];
        NSString *parentViewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",parentViewName] frame:superView.frame superFrame:superView.frame];
        
        [[YLMethodManager shareInstance] updateProperty:parent layout:parentViewFrame];
    }
    
    if (aView) {
        *aView = bgView;
    }
    
    return code;
}

+ (NSString *)generateShapeView:(YLPSDLayerRecordInfo *)record view:(UIView **)aView
                      pathLayer:(CAShapeLayer **)pathLayer frame:(CGRect)layerFrame
                           mask:(UIView *)mask
                     originView:(UIView *)originView superView:(UIView *)superView rate:(CGFloat)rate {
    
    NSInteger overlayRGBAIndex = 0;
    YLRGBA *overlayRGBA = [record getOverlayRGBA:&overlayRGBAIndex];
    
    //是否为图层遮罩，待确认
    BOOL isMask = mask?((record.flags & (0x01 << 3)) > 0):NO;
    UIView *bgView = [[UIView alloc] initWithFrame:layerFrame];
    [superView insertSubview:bgView atIndex:0];
    UIView *pathView = isMask?(mask?:bgView):bgView;
    YLPSDAdditionalLayerInfo *addtional = [record.adjustments objectForKey:@"vmsk"];
    NSArray *value = [[addtional.result objectForKey:@"vmsk"] objectForKey:@"knots"];
    if (!value) {
        addtional = [record.adjustments objectForKey:@"vsms"];
        value = [[addtional.result objectForKey:@"vsms"] objectForKey:@"knots"];
    }
    
    NSString *viewName = [[self class] replaceSpecialWord:record.name.text];
    
    NSString *viewAlpha = [[self class] setAlpha:record layer:bgView.layer name:[NSString stringWithFormat:@"_%@.layer",viewName]];
    NSString *code = [NSString stringWithFormat:@"if (!_%@) {\n"
                      "_%@ = [[UIView alloc] init];\n"
                      "%@", viewName, viewName, viewAlpha];
         
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(layerFrame), CGRectGetHeight(layerFrame))];
    
//    NSString *pathCode = @"";
    
    NSString *valueCode = [NSString stringWithFormat:@"[self addSubview:self.%@];\n",viewName];

    BOOL isLayer = NO;
    if (value.count > 1 || (record.bgColor.circular.shapeType != 1
                            && record.bgColor.circular.shapeType != 2)) {
        
        isLayer = YES;
        NSString *pointsDataCode = [NSString stringWithFormat:@"NSMutableArray *%@_shapePoints = [NSMutableArray array];\n",viewName];
        NSMutableArray *shapePoints = [NSMutableArray arrayWithCapacity:value.count];
        for (NSDictionary *points in value) {
            NSMutableArray *shape_points = [NSMutableArray arrayWithCapacity:points.count];
            pointsDataCode = [pointsDataCode stringByAppendingFormat:@"NSMutableArray *%@_shape_points = [NSMutableArray array];\n",viewName];
            pointsDataCode = [pointsDataCode stringByAppendingFormat:@"NSMutableDictionary *%@_realDic;\n",viewName];
            for (NSDictionary *dic in [points objectForKey:@"points"]) {
                CGPoint anchor = [[dic objectForKey:@"anchor"] CGPointValue];
                CGPoint current = [[self class] postionInView:originView refer:pathView point:anchor];
                NSMutableDictionary *realDic = [[NSMutableDictionary alloc] initWithDictionary:dic copyItems:YES];
                pointsDataCode = [pointsDataCode stringByAppendingFormat:@"%@_realDic = [[NSMutableDictionary alloc] init];\n",viewName];
                pointsDataCode = [pointsDataCode stringByAppendingFormat:@"[%@_realDic setValue:@\"%@\" forKey:@\"type\"];\n", viewName,[dic objectForKey:@"type"]];

                [realDic setValue:[NSValue valueWithCGPoint:current] forKey:@"anchor"];
                pointsDataCode = [pointsDataCode stringByAppendingFormat:@"[%@_realDic setValue:CGPointMake(%.1f,%.1f) forKey:@\"current\"];\n",viewName,current.x,current.y];

                CGPoint preceding = [[dic objectForKey:@"preceding"] CGPointValue];
                CGPoint precede = [[self class] postionInView:originView refer:pathView point:preceding];
                [realDic setValue:[NSValue valueWithCGPoint:precede] forKey:@"preceding"];
                pointsDataCode = [pointsDataCode stringByAppendingFormat:@"[%@_realDic setValue:CGPointMake(%.1f,%.1f) forKey:@\"preceding\"];\n",viewName,precede.x,precede.y];

                CGPoint leaving = [[dic objectForKey:@"leaving"] CGPointValue];
                CGPoint leave = [[self class] postionInView:originView refer:pathView point:leaving];
                [realDic setValue:[NSValue valueWithCGPoint:leave] forKey:@"leaving"];
                pointsDataCode = [pointsDataCode stringByAppendingFormat:@"[%@_realDic setValue:CGPointMake(%.1f,%.1f) forKey:@\"leaving\"];\n",viewName,leave.x,leave.y];
                
                [shape_points addObject:realDic];
                pointsDataCode = [pointsDataCode stringByAppendingFormat:@"[%@_shape_points addObject:%@_realDic];\n",viewName,viewName];
            }
            [shapePoints addObject:shape_points];
            pointsDataCode = [pointsDataCode stringByAppendingFormat:@"[%@_shapePoints addObject:%@_shape_points];\n",viewName,viewName];
        }

        if (!isMask) {
            UIColor *fillColor = [YLRGBA colorWithRGBA:record.bgColor overlay:overlayRGBA];
            YLRGBA *fillRGBA = [YLRGBA rgbaColorFromUIColor:fillColor];
            NSString *shapeMethod = [NSString stringWithFormat:@"CAShapeLayer *%@_shapeLayer = [GlobalMethod getShapeLayer:%@_shapePoints fillColor:%@ stokeColor:%@ frame:CGRectMake(0, 0, %.1f, %.1f)];\n",
                                     viewName,viewName,
                                     [self colorStringWithRGBA:fillRGBA],
                                     [self colorStringWithRGBA:fillRGBA],
                                     ceil(bgView.bounds.size.width), ceil(bgView.bounds.size.height)];
            
            shapeLayer = [[self class] getShapeLayer:originView refer:pathView points:value frame:CGRectMake(0, 0, CGRectGetWidth(layerFrame), CGRectGetHeight(layerFrame)) fillColor:fillColor stokeColor:fillColor record:record];
            [bgView.layer addSublayer:shapeLayer];
            valueCode = [valueCode stringByAppendingFormat:@"%@%@[self.%@.layer addSublayer:%@_shapeLayer];\n", pointsDataCode,shapeMethod,viewName,viewName];
        }

    } else {
        CGRect pathRect = [superView convertRect:layerFrame toView:pathView];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:[record.bgColor.circular cornerRadius]];
        
        UIColor *fillColor = [YLRGBA colorWithRGBA:record.bgColor overlay:overlayRGBA];
        YLRGBA *fillRGBA = [YLRGBA rgbaColorFromUIColor:fillColor];
        if (isMask) {
            shapeLayer.path = path.CGPath;
            shapeLayer.lineCap = kCALineCapButt;
            
            shapeLayer.strokeColor = fillColor.CGColor;
            shapeLayer.fillColor = fillColor.CGColor;
        }

        [bgView setBackgroundColor:fillColor];
        valueCode = [valueCode stringByAppendingFormat:@"[self.%@ setBackgroundColor:%@];\n",
        viewName,[self colorStringWithRGBA:fillRGBA]];
    }
        
    if (record.bgColor.circular) {
        bgView.layer.cornerRadius = [record.bgColor.circular cornerRadius];
        if ([record.bgColor.circular cornerRadius] > 0) {
            code = [code stringByAppendingFormat:@"_%@.layer.cornerRadius = %ld;\n", viewName,(long)[record.bgColor.circular cornerRadius]];
        }
    }
    if (isMask) {
        mask.layer.mask = shapeLayer;
        mask = nil;
    } else {
        if (pathLayer) {
            *pathLayer = shapeLayer;
        }
    }
    
    if (aView) {
        *aView = bgView;
    }
    
    CAGradientLayer *gradientLayer;
    NSString *gradientName = [NSString stringWithFormat:@"%@_overGrad",viewName];
    valueCode = [valueCode stringByAppendingString:[[self class] addEffectGradient:bgView.layer gradient:&gradientLayer record:record mixColor:nil viewName:gradientName]];
    if (gradientLayer) {
        [bgView.layer addSublayer:gradientLayer];
        valueCode = [valueCode stringByAppendingFormat:@"[self.%@.layer addSublayer:%@];\n",viewName,gradientName];
    }
    
    if (isLayer) {
        valueCode = [valueCode stringByAppendingString:[[self class] addEffectStoke:shapeLayer record:record viewName:[NSString stringWithFormat:@"%@_shapeLayer",viewName]]];
    } else {
        valueCode = [valueCode stringByAppendingString:[[self class] addEffectStoke:bgView.layer record:record viewName:[NSString stringWithFormat:@"self.%@.layer",viewName]]];
    }
    
    code = [code stringByAppendingFormat:@"}\nreturn _%@;\n",viewName];
    
    NSString *viewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",viewName] frame:layerFrame superFrame:superView.frame];
    
    record.classView = bgView;
    [[YLMethodManager shareInstance] insertProperty:record viewClass:nil superClass:@"UIView" value:valueCode layout:viewFrame initial:code calculateSize:[NSString stringWithFormat:@"%.1f",CGRectGetHeight(layerFrame)]];
    
    BOOL superChanged = [[self class] adjustSuperFrame:superView contentView:bgView];
    if (superChanged) {
        YLPSDLayerRecordInfo *parent = record.parentRecord;
        NSString *parentViewName = [[self class] replaceSpecialWord:parent.name.text];
        NSString *parentViewFrame = [[self class] setFrame:[NSString stringWithFormat:@"_%@",parentViewName] frame:superView.frame superFrame:superView.frame];
        
        [[YLMethodManager shareInstance] updateProperty:parent layout:parentViewFrame];
    }
    
    return code;
}

+ (NSString *)setFrame:(NSString *)viewName frame:(CGRect)frame superFrame:(CGRect)superFrame {
//    NSInteger left = CGRectGetMinX(frame);
//    NSInteger top = CGRectGetMinY(frame);
//    NSString *width = [NSString stringWithFormat:@"%.1f",CGRectGetWidth(frame)];
//    if (fabs((CGRectGetWidth(superFrame) - CGRectGetWidth(frame))/2 - CGRectGetMinX(frame)) <= 2) {
//        left = (CGRectGetWidth(superFrame) - CGRectGetWidth(frame))/2;
//        width = [NSString stringWithFormat:@"CGRectGetWidth(self.frame) - %ld * 2",(long)left];
//    }
//    NSString *height = [NSString stringWithFormat:@"%.1f",CGRectGetHeight(frame)];
//    if (fabs((CGRectGetHeight(superFrame) - CGRectGetHeight(frame))/2 - CGRectGetMinY(frame)) <= 2) {
//        top = (CGRectGetWidth(superFrame) - CGRectGetWidth(frame))/2;
//        height = [NSString stringWithFormat:@"CGRectGetHeight(self.frame) - %ld * 2",(long)top];
//    }
//    NSString *viewFrame = [NSString stringWithFormat:@"[%@ setFrame:CGRectMake(%ld, %ld, %@, %@)];\n",viewName, left, top, width, height];
//    viewFrame = [viewFrame stringByAppendingFormat:@"[%@ setFrame:CGRectMake(%.1f, %.1f, %.1f, %.1f)];\n",viewName,CGRectGetMinX(frame),CGRectGetMinY(frame),CGRectGetWidth(frame),CGRectGetHeight(frame)];
    NSString *viewFrame = [NSString stringWithFormat:@"[%@ setFrame:CGRectMake(%.1f, %.1f, %.1f, %.1f)];\n", viewName, ceil(CGRectGetMinX(frame)), ceil(CGRectGetMinY(frame)), ceil(CGRectGetWidth(frame)), ceil(CGRectGetHeight(frame))];
    return viewFrame;
}

+ (NSString *)replaceSpecialWord:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    return string.lowercaseString;
}

+ (BOOL)adjustSuperFrame:(UIView *)superView contentView:(UIView *)contentView {
    if (contentView && !CGRectContainsRect(superView.frame, contentView.frame)) {
        CGRect frame = superView.frame;
        if (CGRectGetMaxY(contentView.frame) > CGRectGetHeight(superView.frame)) {
            frame.size.height = ceil(CGRectGetMaxY(contentView.frame));
        }
        if (CGRectGetMaxX(contentView.frame) > CGRectGetWidth(superView.frame)) {
            frame.size.width = ceil(CGRectGetMaxX(contentView.frame));
        }
        superView.frame = frame;
        return YES;
    }
    return NO;
}

+ (NSString *)colorStringWithRGBA:(YLRGBA *)rgba {
    if (rgba.red == rgba.green && rgba.red == rgba.blue) {
        if (rgba.alpha == 255) {
            if (rgba.red == 255) {
                return @"[UIColor whiteColor]";
            } else if (rgba.red == 0) {
                return @"[UIColor blackColor]";
            }
        }
        return [NSString stringWithFormat:@"[UIColor colorWithWhite:%d/255.0 alpha:%d/255.0]",rgba.red,rgba.alpha];
    }
    return [NSString stringWithFormat:@"[UIColor colorWithRed:%d/255.0 green:%d/255.0 blue:%d/255.0 alpha:%d/255.0]",rgba.red,rgba.green,rgba.blue,rgba.alpha];
}

@end
