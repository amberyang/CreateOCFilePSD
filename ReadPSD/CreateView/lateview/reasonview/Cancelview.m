//
//  Cancelviewm
//  workspace
//
//  Created by  on 2020/08/06.
//  Copyright © 202年 . All rights reserved.
//


#import "Cancelview.h"


@interface Cancelview()

@property (nonatomic, strong) UIImageView *cancelbg;
@property (nonatomic, strong) UILabel *canceltext;
@end

@implementation Cancelview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self p_setUp];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self p_layout];
}

- (void)p_setUp {
    //----------------
    [self addSubview:self.cancelbg];
    UIImage *image = [UIImage imageNamed:@"cancelbg.png"];
    self.cancelbg.image = image;
    
    //----------------
    [self addSubview:self.canceltext];
    [self.canceltext setText:@"司机迟到"];
    
    [self setNeedsLayout];
 }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    //----------------
    totalHeight += 73.5;
    
    //----------------
    
    
    return CGSizeMake(size.width, totalHeight);
}

- (void)p_layout {
    //----------------
    [_cancelbg setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    //----------------
    CGSize canceltext_size = [_canceltext sizeThatFits:CGSizeMake((CGRectGetWidth(self.frame) - (2 * 11.0)), CGFLOAT_MAX)];
    [_canceltext setFrame:CGRectMake(((CGRectGetWidth(self.frame)-ceil(canceltext_size.width))/2), ((CGRectGetHeight(_cancelbg.frame)-ceil(canceltext_size.height))/2), ceil(canceltext_size.width), ceil(canceltext_size.height))];
    CATransform3D canceltext_transfrom = CATransform3DMakeRotation(-0.5, 0, 0, 1);
    canceltext_transfrom = CATransform3DRotate(canceltext_transfrom, 0, 1.0f, 0.0f, 0.0f);
    _canceltext.layer.transform = canceltext_transfrom;
    
}

#pragma mark ---- init

- (UIImageView *)cancelbg {
    if (!_cancelbg) {
        _cancelbg = [[UIImageView alloc] init];
        [_cancelbg setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _cancelbg;
}

- (UILabel *)canceltext {
    if (!_canceltext) {
        _canceltext = [[UILabel alloc] init];
        [_canceltext setTextAlignment:NSTextAlignmentLeft];
        [_canceltext setTextColor:[UIColor colorWithRed:50/255.0 green:77/255.0 blue:119/255.0 alpha:255/255.0]];
        [_canceltext setFont:[UIFont systemFontOfSize:ceil(14.0)]];
        _canceltext.adjustsFontSizeToFitWidth = YES;
    }
    return _canceltext;
}

@end
