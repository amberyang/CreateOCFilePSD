//
//  YLImageProcess.m
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLImageProcess.h"
#import "YLRGBA.h"
#import "YLEffect.h"


@implementation YLImageProcess

UIImage *drawImageWithRGB(NSArray *array, NSInteger width, NSInteger height, YLBGRGBA **bgRGBA) {
    
    if (array.count == 0) {
        return nil;
    }
    
    CGRect myBoundingBox;
    CGContextRef myBitmapContext;
    CGImageRef myImage;
    
    myBoundingBox = CGRectMake (0, 0, width, height);
    myBitmapContext = myCreateBitmapContext(width, height);
    
    YLBGRGBA *bg_rgba = [[YLBGRGBA alloc] init];
    YLRGBA *lastRGB = nil;
    
    for (NSInteger i=0; i<height; i++) {
        for (NSInteger j=0; j<width; j++) {
            if (array.count < (i*width + (j+1))) {
                break;
            }
                        
            YLRGBA *rgba = [array objectAtIndex:(i*width+j)];
            
//            NSLog(@"circus (%ld,%ld) is diff: current - %@, last: - %@", j,i,rgba.description,lastRGB.description);
                        
            if (bgRGBA && bg_rgba.sameRGB && lastRGB) {
                BOOL isSameColor = [rgba isEqual:lastRGB];
                if (bg_rgba.sameColor) {
                    bg_rgba.sameColor = isSameColor;
                }
                bg_rgba.sameRGB = isSameColor;
                if (isSameColor) {
                    bg_rgba.alpha = MAX(rgba.alpha, bg_rgba.alpha);
                } else {
                    bg_rgba.sameRGB = [rgba isEqualWithoutAlpha:lastRGB];
                    if (bg_rgba.sameRGB) {
                        if (bg_rgba.sameRGB) {
                            bg_rgba.alpha = MAX(rgba.alpha, bg_rgba.alpha);

//                            NSLog(@"circus (%ld,%ld) is diff: current - %@, last: - %@", j,i,rgba.description,lastRGB.description);
//                            [bg_rgba.circular.alphaPoints addObject:[NSValue valueWithCGPoint:CGPointMake(j, i)]];
                            lastRGB = rgba;
                        }
                    }
                }
            } else {
                lastRGB = rgba;
            }

            NSInteger r = rgba.red > 255 ? 0:rgba.red;
            NSInteger g = rgba.green > 255 ? 0:rgba.green;
            NSInteger b = rgba.blue > 255 ? 0:rgba.blue;
            NSInteger a = rgba.alpha > 255 ? 255:rgba.alpha;
            
//            [[array objectAtIndex:(i*width+j)] getValue:&rgba];
            CGContextSetRGBFillColor(myBitmapContext, (float)r/255.0, (float)g/255.0, (float)b/255.0, (float)a/255.0);
            CGContextFillRect(myBitmapContext, CGRectMake(j, (height-i), 1, 1));
        }
    }
    
    if (bgRGBA) {
//        if (bg_rgba.sameRGB) {
//            bg_rgba.red = lastRGB.red;
//            bg_rgba.green = lastRGB.green;
//            bg_rgba.blue = lastRGB.blue;
//        }
//        *bgRGBA = bg_rgba;
    }
        
    myImage = CGBitmapContextCreateImage(myBitmapContext);
    CGContextDrawImage(myBitmapContext, myBoundingBox, myImage);
    char *bitmapData = CGBitmapContextGetData(myBitmapContext);
    CGContextRelease (myBitmapContext);
    if (bitmapData)
        free(bitmapData);
    UIImage *image = [UIImage imageWithCGImage:myImage];
    CGImageRelease(myImage);
    
    return image;
}

UIImage *drawImageWithRecord(YLPSDLayerRecordInfo *record, NSArray *array, NSInteger width, NSInteger height, YLBGRGBA **bgRGBA) {
    
    UIImage *image = drawImageWithRGB(array, width, height, bgRGBA);
    
    YLPSDAdditionalLayerInfo *addtional = [record.adjustments objectForKey:@"vscg"];
    NSDictionary *dic = [addtional.result objectForKey:@"vscg"];
    NSString *key = [dic objectForKey:@"vscg_key"];
    if (![key isEqualToString:@"gdfl"]) {
        addtional = [record.adjustments objectForKey:@"gdfl"];
        dic = [addtional.result objectForKey:@"gdfl"];
    }

    if (dic.count > 0) {
        NSArray *result = [[dic objectForKey:@"result"] allValues][0];
        //渐变色
        YLGradient *gradient = [YLGradient createGradientWithArray:result];
        if (bgRGBA) {
            if (!(*bgRGBA)) {
                (*bgRGBA) = [YLBGRGBA new];
                (*bgRGBA).sameColor = NO;
                (*bgRGBA).sameRGB = NO;
            }
            (*bgRGBA).gradient = gradient;
        }
    }
    
    addtional = [record.adjustments objectForKey:@"vogk"];
    dic = [addtional.result objectForKey:@"vogk"];
    if (dic.count > 0) {
        NSArray *result = [[dic objectForKey:@"result"] objectForKey:@"null"];
        if (!result) {
            result = [[dic objectForKey:@"result"] allValues][0];
        }
        //圆角
        YLCircularRadius *circular = [YLCircularRadius createCircularRadiusWithArray:result];
        if ([circular showShape] || [circular cornerRadius] > 0 || [circular adjustFrame]) {
            if (bgRGBA) {
                if (!(*bgRGBA)) {
                    (*bgRGBA) = [YLBGRGBA new];
                }
                addtional = [record.adjustments objectForKey:@"vmsk"];
                key = @"";
                if (addtional) {
                    key = @"vmsk";
                } else {
                    addtional = [record.adjustments objectForKey:@"vsms"];
                    if (addtional) {
                        key = @"vsms";
                    }
                }
                if (key.length > 0) {
                    NSArray *value = [[addtional.result objectForKey:key] objectForKey:@"knots"];
                    if (value && value.count == 0) {
                        (*bgRGBA).sameRGB = NO;
                        (*bgRGBA).sameColor = NO;
                    }
                }
                (*bgRGBA).circular = circular;
            }
        }
        if (circular.showImage) {
            if (bgRGBA) {
                if (!(*bgRGBA)) {
                    (*bgRGBA) = [YLBGRGBA new];
                }
                (*bgRGBA).sameRGB = NO;
                (*bgRGBA).sameColor = NO;
            }
        }
    }
    
    addtional = [record.adjustments objectForKey:@"lfx2"];
    dic = [addtional.result objectForKey:@"lfx2"];

    if (dic.count > 0) {
        //null
        NSArray *result = [[dic objectForKey:@"result"] objectForKey:@"null"];
        if (!result) {
            result = [[dic objectForKey:@"result"] allValues][0];
        }
        //颜色叠加
        id value = [YLEffect getDataWithArray:result key:@[@"sofi",@"objc",@"sofi"]];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *objc = (NSArray *)value;
            if (objc.count > 0) {
                YLRGBA *rgba = [YLRGBA createRGBAWithArray:objc];
                if (bgRGBA && rgba.enab) {
                    if (!(*bgRGBA)) {
                        (*bgRGBA) = [YLBGRGBA new];
                    }
                    (*bgRGBA).effect.rgba = rgba;
                }
            }
        }
        
        //渐变叠加
        value = [YLEffect getDataWithArray:result key:@[@"grfl",@"objc",@"grfl"]];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *objc = (NSArray *)value;
            if (objc.count > 0) {
                YLGradient *gradient = [YLGradient createGradientWithArray:objc];
                if (bgRGBA) {
                    if (!(*bgRGBA)) {
                        (*bgRGBA) = [YLBGRGBA new];
                        (*bgRGBA).sameColor = NO;
                        (*bgRGBA).sameRGB = NO;
                    }
                    (*bgRGBA).effect.gradient = gradient;
                }
            }
        }
        //内阴影
        value = [YLEffect getDataWithArray:result key:@[@"irsh",@"objc",@"irsh"]];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *objc = (NSArray *)value;
            if (objc.count > 0) {
                YLInsideShadow *irsh = [YLInsideShadow createInsideShadowWithArray:objc];
                if (bgRGBA) {
                    if (!(*bgRGBA)) {
                        (*bgRGBA) = [YLBGRGBA new];
                        (*bgRGBA).sameColor = NO;
                        (*bgRGBA).sameRGB = NO;
                    }
                    (*bgRGBA).effect.irsh = irsh;
                }
            }
        }
        //描边色
        value = [YLEffect getDataWithArray:result key:@[@"frfx",@"objc",@"frfx"]];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *objc = (NSArray *)value;
            if (objc.count > 0) {
                YLEffectStroke *frfx = [YLEffectStroke createStokeWithArray:objc];
                if (bgRGBA) {
                    if (!(*bgRGBA)) {
                        (*bgRGBA) = [YLBGRGBA new];
                        (*bgRGBA).sameColor = NO;
                        (*bgRGBA).sameRGB = NO;
                    }
                    (*bgRGBA).effect.frfx = frfx;
                }
            }
        }
    }
    
    addtional = [record.adjustments objectForKey:@"lrfx"];
    dic = [addtional.result objectForKey:@"lrfx"];
    
    if (dic.count > 0) {
        //null
        NSDictionary *result = [dic objectForKey:@"result"];
        //颜色叠加
        id value = [[result objectForKey:@"sofi"] objectForKey:@"overlay"];
        if ([value isKindOfClass:[YLRGBA class]]) {
            if (bgRGBA) {
                if (!(*bgRGBA)) {
                    (*bgRGBA) = [YLBGRGBA new];
                }
                (*bgRGBA).effect.rgba = (YLRGBA *)value;
            }
        }

//        //渐变叠加
//        value = [YLEffect getDataWithArray:result key:@[@"grfl",@"objc"]];
//        if ([value isKindOfClass:[NSArray class]]) {
//            NSArray *objc = (NSArray *)value;
//            if (objc.count > 0) {
//                YLGradient *gradient = [YLGradient createGradientWithArray:objc];
//                if (bgRGBA) {
//                    if (!(*bgRGBA)) {
//                        (*bgRGBA) = [YLBGRGBA new];
//                        (*bgRGBA).sameColor = NO;
//                        (*bgRGBA).sameRGB = NO;
//                    }
//                    (*bgRGBA).effect.gradient = gradient;
//                }
//            }
//        }
    }
    
    addtional = [record.adjustments objectForKey:@"vscg"];
    if (![key isEqualToString:@"soco"]) {
        addtional = [record.adjustments objectForKey:@"soco"];
        if (!addtional) {
            addtional = [record.adjustments objectForKey:@"soco"];
        }
    }
    dic = [addtional.result objectForKey:@"soco"];

    if (dic.count > 0) {
        NSArray *result = [[dic objectForKey:@"result"] objectForKey:@"null"];
        if (!result) {
            result = [[dic objectForKey:@"result"] allValues][0];
        }
        //填充色
        YLRGBA *rgba = [YLRGBA createRGBAWithArray:result];
        if (bgRGBA) {
            if (!(*bgRGBA)) {
                (*bgRGBA) = [YLBGRGBA new];
            }
            if ([(*bgRGBA).circular showShape] || [(*bgRGBA).circular cornerRadius] > 0) {
//                addtional = [record.adjustments objectForKey:@"vmsk"];
//                NSArray *value = [[addtional.result objectForKey:@"vmsk"] objectForKey:@"knots"];
//                if (value.count > 1) {
//                   (*bgRGBA).sameRGB = NO;
//                    (*bgRGBA).sameColor = NO;
//                } else {
                    (*bgRGBA).sameRGB = YES;
                    (*bgRGBA).sameColor = YES;
//                }
            }
//            else if ([(*bgRGBA).circular cornerRadius] == 0 && record.hasMask) {
//                (*bgRGBA).sameRGB = NO;
//                (*bgRGBA).sameColor = NO;
//            }
            else {
                addtional = [record.adjustments objectForKey:@"clbl"];
                dic = [addtional.result objectForKey:@"clbl"];
                if ((record.flags & (0x01 << 4)) > 0 && [[dic objectForKey:@"blend_clip"] boolValue]) {
                    if ((*bgRGBA).gradient || (*bgRGBA).effect.gradient) {
                        (*bgRGBA).sameRGB = YES;
                        (*bgRGBA).sameColor = YES;
                    } else {
                        (*bgRGBA).sameRGB = NO;
                        (*bgRGBA).sameColor = NO;
                    }
                } else {
                    (*bgRGBA).sameRGB = YES;
                    (*bgRGBA).sameColor = YES;
                }
            }
            (*bgRGBA).red = rgba.red;
            (*bgRGBA).green = rgba.green;
            (*bgRGBA).blue = rgba.blue;
            (*bgRGBA).alpha = rgba.alpha;
        }
    }
    
//    addtional = [record.adjustments objectForKey:@"lrfx"];
//    dic = [addtional.result objectForKey:@"lrfx"];
    //描边色
//    if (dic.count > 0) {
//        NSArray *result = [dic objectForKey:@"result"];
//
//    }
    
    
    //vstk 描边属性
    addtional = [record.adjustments objectForKey:@"vstk"];
    dic = [addtional.result objectForKey:@"vstk"];
    if (dic.count > 0) {
        NSArray *value = [[dic objectForKey:@"result"] objectForKey:@"strokestyle"];
        YLStroke *stoke = [YLStroke createStokeWithArray:value];
        if (stoke.strokeenabled) {
            if (!(*bgRGBA)) {
                (*bgRGBA) = [YLBGRGBA new];
            }
            (*bgRGBA).stoke = stoke;
        }
    }
    //strokeEnabled
    //fillEnabled
    //strokeStyleLineWidth
    //solidColorLayer
    
    return image;
}


CGContextRef myCreateBitmapContext(NSInteger width, NSInteger height) {
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    NSInteger *          bitmapData;
    NSInteger            bitmapByteCount;
    NSInteger            bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * height);
    
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    bitmapData = (NSInteger *)calloc( bitmapByteCount, sizeof(uint8_t) );
    if (bitmapData == NULL)
    {
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,
                                     width,
                                     height,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
    if (context== NULL)
    {
        free (bitmapData);
        return NULL;
    }
    return context;
}


@end
