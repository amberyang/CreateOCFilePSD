//
//  ViewController.m
//  ReadPSD
//
//  Created by amber on 2019/7/31.
//  Copyright © 2019 amber. All rights reserved.
//

#import "ViewController.h"
#import "YLPSDHeader.h"
#import "YLPSDColorModeData.h"
#import "YLPSDImageResource.h"
#import "YLPSDLayerAndMask.h"
#import "YLPSDImageData.h"
#import "YLTextInfo.h"
#import "UIImage+Overlay.h"
#import "YLDataProcess.h"
#import "UIView+SecureCoding.h"
#import "UIImageView+SecureCoding.h"
#import "YLCodeBuilder.h"
#import "YLMethodManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageView;
@property (nonatomic, copy) NSString *codeString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    [self parsePSD];
}

- (void)parsePSD {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"test" ofType:@"psd"];
        NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
        NSLog(@"size = %ld字节",fileData.length);

    #pragma mark ------ file header
        
        NSInteger index = 0;
        
        YLPSDHeader *header = [YLPSDHeader new];
        [header parse:fileData index:index];
        index = header.endIndex;

    #pragma mark ------ color mode data
        
        YLPSDColorModeData *colorMode = [YLPSDColorModeData new];
        [colorMode parse:fileData index:index colorMode:header.headerInfo.colorMode];
        index = colorMode.endIndex;
        
    #pragma mark ------ image resource
        
        YLPSDImageResource *imageResource = [YLPSDImageResource new];
        [imageResource parse:fileData index:index];
        index = imageResource.endIndex;
        
    #pragma mark ------ layer and mask information
        
        YLPSDLayerAndMask *layerMask = [YLPSDLayerAndMask new];
        [layerMask parse:fileData index:index channel:header.headerInfo.channels colorMode:header.headerInfo.colorMode];
        index = layerMask.endIndex;
        
    #pragma mark ------ image data
        
        YLPSDImageData *imageData = [YLPSDImageData new];
        [imageData parse:fileData index:index channel:header.headerInfo.channels colorMode:header.headerInfo.colorMode width:header.headerInfo.width height:header.headerInfo.height];
        index = imageData.endIndex;
        
        
    #pragma mark ------ image show
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_scrollView];
        
        CGFloat wRate = self.view.frame.size.width/header.headerInfo.width;
    //    CGFloat hRate = self.view.frame.size.height/header.headerInfo.height;
        
        CGFloat rate = 1;
    //    if (wRate < 1 || hRate < 1) {
    //        rate = MIN(wRate, hRate);
    //    }
        if (wRate < 1) {
            rate = wRate;
        }
        
        NSString *className = @"Soldview";
        Class viewClass = NSClassFromString(className);
        UIView *aView = [[viewClass alloc] init];
    //    [aView setFrame:CGRectMake(0, 0, header.headerInfo.width, header.headerInfo.height)];
        CGFloat wRate1 = self.view.frame.size.width/header.headerInfo.width;
        //    CGFloat hRate = self.view.frame.size.height/header.headerInfo.height;
            
            CGFloat rate1 = 1;
        //    if (wRate < 1 || hRate < 1) {
        //        rate = MIN(wRate, hRate);
        //    }
            if (wRate1 < 1) {
                rate1 = wRate1;
            }
        
        [_scrollView addSubview:aView];

        [aView setFrame:CGRectMake(0, 80, header.headerInfo.width * rate, header.headerInfo.height * rate)];
    //    if (rate1 < 1) {
    //        [aView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, rate1, rate1)];
    //    }
    //    [aView setFrame:CGRectMake(0, 0, CGRectGetWidth(aView.frame), CGRectGetHeight(aView.frame))];
        
    //    return;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(aView.frame)+50, header.headerInfo.width, header.headerInfo.height)];
        [imageView setBackgroundColor:[UIColor whiteColor]];
        [imageView setImage:imageData.imageData.image];
        [_scrollView addSubview:imageView];
        
    //    [self addLayerImage:imageView images:layerMask.layerMaskInfo.layerInfos.records];
        
        if (rate < 1) {
            [imageView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, rate, rate)];
        }
        
        [imageView setFrame:CGRectMake((self.view.frame.size.width - imageView.frame.size.width)/2, CGRectGetMaxY(aView.frame)+50, imageView.frame.size.width, imageView.frame.size.height)];
        
        NSLog(@"~~~~~~~~~~~~ parse end");
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 50, header.headerInfo.width, header.headerInfo.height)];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        [_scrollView addSubview:bgView];
        _imageView = bgView;
        [self addLayerText:bgView records:layerMask.layerMaskInfo.layerInfos.records maskView:nil rate:rate];
//        [bgView setFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 50, header.headerInfo.width, header.headerInfo.height)];
        
    //    if (rate < 1) {
    //        [bgView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, rate, rate)];
    //    }
        
    //    [bgView setFrame:CGRectMake((self.view.frame.size.width - bgView.frame.size.width)/2, CGRectGetMaxY(imageView.frame) + 20, bgView.frame.size.width, bgView.frame.size.height)];
        bgView.clipsToBounds = YES;
        [bgView setFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 50, header.headerInfo.width * rate, header.headerInfo.height * rate)];

        [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(bgView.frame) + 40)];
        [_scrollView setBackgroundColor:[UIColor lightGrayColor]];
        
        [[YLMethodManager shareInstance] writeCodeWithRecord:layerMask.layerMaskInfo.layerInfos.records];
}

- (void)addLayerText:(UIView *)superView records:(NSArray *)array
            maskView:(UIView *)maskView rate:(CGFloat)rate {
        
    UIView *mask = maskView;

    for (id object in array) {
        if ([object isKindOfClass:[NSArray class]]) {
            [self addLayerText:superView records:(NSArray *)object maskView:mask rate:rate];
        } else {
            YLPSDLayerRecordInfo *layerObj = (YLPSDLayerRecordInfo *)object;
            if ((layerObj.flags & (0x01 << 1)) > 0) {
                continue;
            }
            CGRect layerFrame = CGRectMake(layerObj.layerInsets.left, layerObj.layerInsets.top, (layerObj.layerInsets.right-layerObj.layerInsets.left), (layerObj.layerInsets.bottom-layerObj.layerInsets.top));
            if ([layerObj.bgColor.circular adjustFrame]) {
                layerFrame = CGRectMake(layerObj.layerInsets.left, layerObj.layerInsets.top, (layerObj.bgColor.circular.rght-layerObj.bgColor.circular.left), (layerObj.bgColor.circular.btom-layerObj.bgColor.circular.top));
            }
            
            layerFrame = CGRectMake(CGRectGetMinX(layerFrame)*rate, CGRectGetMinY(layerFrame)*rate, CGRectGetWidth(layerFrame)*rate, CGRectGetHeight(layerFrame)*rate);
            
            UIView *contentView = nil;

            if ([layerObj.adjustments.allKeys containsObject:@"tysh"]) {
                UILabel *label;
                [YLCodeBuilder generateLabel:layerObj label:&label frame:layerFrame superView:superView rate:rate];
                [superView insertSubview:label atIndex:0];
                contentView = label;
            } else if(layerObj.bgColor.gradient && layerObj.image) {
                UIView *bgView;
                [YLCodeBuilder generateGradientView:layerObj view:&bgView gradientLayer:nil frame:layerFrame superView:superView rate:rate];
                [superView insertSubview:bgView atIndex:0];
                contentView = bgView;
            } else if (layerObj.bgColor.sameRGB && layerObj.image) {
                UIView *bgView;
                CAShapeLayer *shapeLayer;
                [YLCodeBuilder generateShapeView:layerObj view:&bgView pathLayer:&shapeLayer frame:layerFrame mask:mask originView:_imageView superView:superView rate:rate];
                [superView insertSubview:bgView atIndex:0];
                contentView = bgView;

            } else if (layerObj.image) {
                UIImageView *layerImage;
                [YLCodeBuilder generateImageView:layerObj imageView:&layerImage frame:layerFrame superView:superView rate:rate];
                [superView insertSubview:layerImage atIndex:0];
                contentView = layerImage;
            }
            
            if (layerObj.clipping == 1) {
                if (mask) {
                    [contentView removeFromSuperview];
                } else {
                    mask = contentView;
                }
            }
                        
            if (layerObj.bgColor.effect.irsh && contentView) {
                YLInsideShadow *irsh = layerObj.bgColor.effect.irsh;
                if (round(irsh.lagl) == 90) {

                } else {
                    
                }
                //一般用不到内阴影，所以随便遮罩一下
            }
            
//            if (layerObj.bgColor.effect.frfx && !isStroke) {
//                YLEffectStroke *frfx = layerObj.bgColor.effect.frfx;
//                if (frfx.sz > 0) {
//                    if ([frfx.styl isEqualToString:@"InsF"]) {
//                        contentView.layer.borderWidth = frfx.sz;
//                        contentView.layer.borderColor = [YLRGBA colorWithRGBA:frfx.rgba].CGColor;
//                    } else if ([frfx.styl isEqualToString:@"OutF"]) {
//                        UIView *copyView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(contentView.frame)-frfx.sz, CGRectGetMinY(contentView.frame)-frfx.sz, CGRectGetWidth(contentView.frame)+(frfx.sz*2), CGRectGetHeight(contentView.frame)+(frfx.sz*2))];
//                        [contentView setFrame:CGRectMake(frfx.sz, frfx.sz, CGRectGetWidth(contentView.frame), CGRectGetHeight(contentView.frame))];
//                        copyView.layer.cornerRadius = contentView.layer.cornerRadius;
//                        [copyView setBackgroundColor:[YLRGBA colorWithRGBA:frfx.rgba]];
//                        [copyView addSubview:contentView];
//                        contentView = copyView;
//                        [superView insertSubview:contentView atIndex:0];
//                    }
//                }
//            }
            
            if (contentView && !CGRectContainsRect(superView.frame, contentView.frame)) {
                CGRect frame = superView.frame;
                if (CGRectGetMaxY(contentView.frame) > CGRectGetHeight(superView.frame)) {
                    frame.size.height = CGRectGetMaxY(contentView.frame);
                }
                if (CGRectGetMaxX(contentView.frame) > CGRectGetWidth(superView.frame)) {
                    frame.size.width = CGRectGetMaxX(contentView.frame);
                }
                superView.frame = frame;
            }
            
            if (layerObj.records.count > 0) {
                if (!contentView) {
                    UIView *bgView;
                    [YLCodeBuilder generateView:layerObj view:&bgView frame:layerFrame superView:superView rate:rate];
                    [superView insertSubview:bgView atIndex:0];
                    [self addLayerText:bgView records:layerObj.records maskView:mask rate:rate];
                } else {
                    [self addLayerText:contentView records:layerObj.records maskView:mask rate:rate];
                }
            }
        }
    }
}

#pragma mark ---- create image
- (void)addLayerImage:(UIView *)superView images:(NSArray *)array {
    for (id object in array) {
        if ([object isKindOfClass:[NSArray class]]) {
            [self addLayerImage:superView images:(NSArray *)object];
        } else {
            YLPSDLayerRecordInfo *layerObj = (YLPSDLayerRecordInfo *)object;
            NSLog(@"~~~~%d~~~~%d",((layerObj.flags & (0x01 << 1)) > 0),layerObj.records.count>0);
            if (layerObj.image) {
                UIImageView *layerImage = [[UIImageView alloc] initWithImage:layerObj.image];
                [layerImage setContentMode:UIViewContentModeScaleAspectFit];
                [layerImage setFrame:CGRectMake(layerObj.layerInsets.left, layerObj.layerInsets.top, layerObj.layerInsets.right-layerObj.layerInsets.left, layerObj.layerInsets.bottom-layerObj.layerInsets.top)];
                [superView insertSubview:layerImage atIndex:0];
            }
            if (layerObj.records.count > 0) {
                [self addLayerImage:superView images:(NSArray *)layerObj.records];
            }
        }
    }
}

- (CGPoint)realPoint:(CGPoint)anchorPoint {
    return CGPointMake(anchorPoint.x, anchorPoint.y);
}

@end

