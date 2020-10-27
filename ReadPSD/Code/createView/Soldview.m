//
//  Soldviewm
//  workspace
//
//  Created by  on 2020/10/27.
//  Copyright © 202年 . All rights reserved.
//


#import "Soldview.h"


@interface Soldview()

@property (nonatomic, strong) UIImageView *viewbg;
@property (nonatomic, strong) UILabel *desclabel;
@property (nonatomic, strong) UILabel *titlelabel;
@property (nonatomic, strong) UIImageView *buttonbg;
@property (nonatomic, strong) UILabel *buttontext;
@property (nonatomic, strong) UIImageView *textbg;
@property (nonatomic, strong) UILabel *textlabel;
@end

@implementation Soldview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self p_setUp];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self p_layout];
}

- (void)p_setUp {
    //----------------
    [self addSubview:self.viewbg];
    UIImage *viewbg_image = [UIImage imageNamed:@"viewbg.png"];
    self.viewbg.image = viewbg_image;
    
    //----------------
    [self addSubview:self.desclabel];
    [self.desclabel setText:@"最多十五个字符"];
    
    //----------------
    [self addSubview:self.titlelabel];
    [self.titlelabel setText:@"最多十个字符"];
    
    //----------------
    [self addSubview:self.buttonbg];
    UIImage *buttonbg_image = [UIImage imageNamed:@"buttonbg.png"];
    self.buttonbg.image = buttonbg_image;
    
    //----------------
    [self addSubview:self.buttontext];
    [self.buttontext setText:@"按钮文字"];
    
    //----------------
    [self addSubview:self.textbg];
    UIImage *textbg_image = [UIImage imageNamed:@"textbg.png"];
    self.textbg.image = textbg_image;
    
    //----------------
    [self addSubview:self.textlabel];
    [self.textlabel setText:@"12月26日"];
    
    [self setNeedsLayout];
 }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    //----------------
    totalHeight += 150.2;
    
    //----------------
    
    //----------------
    
    //----------------
    
    //----------------
    
    //----------------
    totalHeight += 91.9;
    
    //----------------
    
    
    return CGSizeMake(size.width, totalHeight);
}

- (void)p_layout {
    //----------------
    [_viewbg setFrame:CGRectMake(0.0, 0.0, 376.0, CGRectGetHeight(self.frame))];
    
    //----------------
    CGSize desclabel_size = [_desclabel sizeThatFits:CGSizeMake(105.0, CGFLOAT_MAX)];
    [_desclabel setFrame:CGRectMake(23.0, ((CGRectGetHeight(_viewbg.frame)-ceil(desclabel_size.height))/2), ceil(desclabel_size.width), ceil(desclabel_size.height))];
    
    //----------------
    CGSize titlelabel_size = [_titlelabel sizeThatFits:CGSizeMake(ceil(titlelabel_size.width), CGFLOAT_MAX)];
    [_titlelabel setFrame:CGRectMake(CGRectGetMinX(_desclabel.frame), 25.0, ceil(titlelabel_size.width), ceil(titlelabel_size.height))];
    
    //----------------
    [_buttonbg setFrame:CGRectMake(22.0, (CGRectGetMaxY(_titlelabel.frame)+44.0), 83.0, 32.0)];
    
    //----------------
    CGSize buttontext_size = [_buttontext sizeThatFits:CGSizeMake(52.0, CGFLOAT_MAX)];
    [_buttontext setFrame:CGRectMake(37.0, (CGRectGetMinY(_buttonbg.frame)+(CGRectGetHeight(_buttonbg.frame)-ceil(buttontext_size.height))/2), ceil(buttontext_size.width), ceil(buttontext_size.height))];
    
    //----------------
    [_textbg setFrame:CGRectMake(306.0, -25.0, 93.0, 92.0)];
    
    //----------------
    CGSize textlabel_size = [_textlabel sizeThatFits:CGSizeMake(37.0, CGFLOAT_MAX)];
    [_textlabel setFrame:CGRectMake(337.0, (CGRectGetMinY(_textbg.frame)+(CGRectGetHeight(_textbg.frame)-ceil(textlabel_size.height))/2), ceil(textlabel_size.width), ceil(textlabel_size.height))];
    CATransform3D textlabel_transfrom = CATransform3DMakeRotation(0.78, 0, 0, 1);
    textlabel_transfrom = CATransform3DRotate(textlabel_transfrom, 0, 1.0f, 0.0f, 0.0f);
    _textlabel.layer.transform = textlabel_transfrom;
}

#pragma mark ---- init

- (UIImageView *)viewbg {
    if (!_viewbg) {
        _viewbg = [[UIImageView alloc] init];
        [_viewbg setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _viewbg;
}

- (UILabel *)desclabel {
    if (!_desclabel) {
        _desclabel = [[UILabel alloc] init];
        [_desclabel setTextAlignment:NSTextAlignmentLeft];
        [_desclabel setTextColor:[UIColor whiteColor]];
        [_desclabel setFont:[UIFont systemFontOfSize:ceil(16.0)]];
        _desclabel.adjustsFontSizeToFitWidth = YES;
    }
    return _desclabel;
}

- (UILabel *)titlelabel {
    if (!_titlelabel) {
        _titlelabel = [[UILabel alloc] init];
        [_titlelabel setTextAlignment:NSTextAlignmentLeft];
        [_titlelabel setTextColor:[UIColor whiteColor]];
        [_titlelabel setFont:[UIFont systemFontOfSize:ceil(24.0)]];
        _titlelabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titlelabel;
}

- (UIImageView *)buttonbg {
    if (!_buttonbg) {
        _buttonbg = [[UIImageView alloc] init];
        [_buttonbg setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _buttonbg;
}

- (UILabel *)buttontext {
    if (!_buttontext) {
        _buttontext = [[UILabel alloc] init];
        [_buttontext setTextAlignment:NSTextAlignmentLeft];
        [_buttontext setTextColor:[UIColor whiteColor]];
        [_buttontext setFont:[UIFont systemFontOfSize:ceil(13.0)]];
        _buttontext.adjustsFontSizeToFitWidth = YES;
    }
    return _buttontext;
}

- (UIImageView *)textbg {
    if (!_textbg) {
        _textbg = [[UIImageView alloc] init];
        [_textbg setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _textbg;
}

- (UILabel *)textlabel {
    if (!_textlabel) {
        _textlabel = [[UILabel alloc] init];
        [_textlabel setTextAlignment:NSTextAlignmentLeft];
        [_textlabel setTextColor:[UIColor whiteColor]];
        [_textlabel setFont:[UIFont systemFontOfSize:ceil(11.0)]];
        _textlabel.adjustsFontSizeToFitWidth = NO;
    }
    return _textlabel;
}

@end
