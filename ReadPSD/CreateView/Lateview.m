//
//  Lateviewm
//  workspace
//
//  Created by  on 2020/08/06.
//  Copyright © 202年 . All rights reserved.
//


#import "Lateview.h"
#import "Reasonview.h"
#import "Explainview.h"


@interface Lateview()

@property (nonatomic, strong) UIImageView *bgview;
@property (nonatomic, strong) Reasonview *reasonview;
@property (nonatomic, strong) UIView *notcancelbg;
@property (nonatomic, strong) UILabel *notcancel;
@property (nonatomic, strong) UIView *cancelbg;
@property (nonatomic, strong) UILabel *cancel;
@property (nonatomic, strong) Explainview *explainview;
@end

@implementation Lateview

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
    [self addSubview:self.bgview];
    UIImage *image = [UIImage imageNamed:@"bgview.png"];
    self.bgview.image = image;
    
    //----------------
    [self addSubview:self.reasonview];
    
    //----------------
    [self addSubview:self.notcancelbg];
    [self.notcancelbg setBackgroundColor:[UIColor whiteColor]];
    self.notcancelbg.layer.borderColor = [UIColor colorWithWhite:229/255.0 alpha:255/255.0].CGColor;
    self.notcancelbg.layer.borderWidth = 1.0;
    
    //----------------
    [self addSubview:self.notcancel];
    [self.notcancel setText:@"暂不取消"];
    
    //----------------
    [self addSubview:self.cancelbg];
    [self.cancelbg setBackgroundColor:[UIColor colorWithWhite:35/255.0 alpha:255/255.0]];
    
    //----------------
    [self addSubview:self.cancel];
    [self.cancel setText:@"确认取消"];
    
    //----------------
    [self addSubview:self.explainview];
    
    [self setNeedsLayout];
 }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    //----------------
    totalHeight += 667.0;
    
    //----------------
    
    //----------------
    
    //----------------
    
    //----------------
    
    //----------------
    
    //----------------
    
    
    return CGSizeMake(size.width, totalHeight);
}

- (void)p_layout {
    //----------------
    [_bgview setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    //----------------
    CGSize reasonview_size = [_reasonview sizeThatFits:CGSizeMake((CGRectGetWidth(self.frame) - (2 * 16.0)), CGFLOAT_MAX)];
    [_reasonview setFrame:CGRectMake(((CGRectGetWidth(self.frame)-ceil(reasonview_size.width))/2), 175.0, ceil(reasonview_size.width), ceil(reasonview_size.height))];
    
    //----------------
    [_notcancelbg setFrame:CGRectMake(9.0, (CGRectGetMaxY(_reasonview.frame)+16.0), (CGRectGetWidth(self.frame)-(2*9.0)), 52.0)];
    
    //----------------
    CGSize notcancel_size = [_notcancel sizeThatFits:CGSizeMake((CGRectGetWidth(self.frame) - (2 * 156.0)), CGFLOAT_MAX)];
    [_notcancel setFrame:CGRectMake(((CGRectGetWidth(self.frame)-ceil(notcancel_size.width))/2), (CGRectGetMinY(_notcancelbg.frame)+(CGRectGetHeight(_notcancelbg.frame)-ceil(notcancel_size.height))/2), ceil(notcancel_size.width), ceil(notcancel_size.height))];
    _notcancel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    
    //----------------
    [_cancelbg setFrame:CGRectMake(CGRectGetMinX(_notcancelbg.frame), (CGRectGetMaxY(_notcancel.frame)+24.0), CGRectGetWidth(_notcancelbg.frame), 52.0)];
    
    //----------------
    CGSize cancel_size = [_cancel sizeThatFits:CGSizeMake(CGRectGetWidth(_notcancel.frame), CGFLOAT_MAX)];
    [_cancel setFrame:CGRectMake(CGRectGetMinX(_notcancel.frame), (CGRectGetMinY(_cancelbg.frame)+(CGRectGetHeight(_cancelbg.frame)-ceil(cancel_size.height))/2), ceil(cancel_size.width), ceil(cancel_size.height))];
    _cancel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    
    //----------------
    CGSize explainview_size = [_explainview sizeThatFits:CGSizeMake((CGRectGetWidth(self.frame) - (2 * 155.0)), CGFLOAT_MAX)];
    [_explainview setFrame:CGRectMake(((CGRectGetWidth(self.frame)-ceil(explainview_size.width))/2), (CGRectGetMaxY(_cancel.frame)+136.0), ceil(explainview_size.width), ceil(explainview_size.height))];
    
}

#pragma mark ---- init

- (UIImageView *)bgview {
    if (!_bgview) {
        _bgview = [[UIImageView alloc] init];
        [_bgview setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _bgview;
}

- (Reasonview *)reasonview {
    if (!_reasonview) {
        _reasonview = [[Reasonview alloc] init];
        _reasonview.clipsToBounds = YES;
    }
    return _reasonview;
}

- (UIView *)notcancelbg {
    if (!_notcancelbg) {
        _notcancelbg = [[UIView alloc] init];
        _notcancelbg.layer.cornerRadius = 8;
    }
    return _notcancelbg;
}

- (UILabel *)notcancel {
    if (!_notcancel) {
        _notcancel = [[UILabel alloc] init];
        [_notcancel setTextAlignment:NSTextAlignmentLeft];
        [_notcancel setTextColor:[UIColor colorWithRed:209/255.0 green:121/255.0 blue:21/255.0 alpha:255/255.0]];
        [_notcancel setFont:[UIFont systemFontOfSize:ceil(14.0)]];
        _notcancel.adjustsFontSizeToFitWidth = YES;
    }
    return _notcancel;
}

- (UIView *)cancelbg {
    if (!_cancelbg) {
        _cancelbg = [[UIView alloc] init];
        _cancelbg.layer.cornerRadius = 8;
    }
    return _cancelbg;
}

- (UILabel *)cancel {
    if (!_cancel) {
        _cancel = [[UILabel alloc] init];
        [_cancel setTextAlignment:NSTextAlignmentLeft];
        [_cancel setTextColor:[UIColor colorWithRed:227/255.0 green:211/255.0 blue:175/255.0 alpha:255/255.0]];
        [_cancel setFont:[UIFont systemFontOfSize:ceil(14.0)]];
        _cancel.adjustsFontSizeToFitWidth = YES;
    }
    return _cancel;
}

- (Explainview *)explainview {
    if (!_explainview) {
        _explainview = [[Explainview alloc] init];
        _explainview.clipsToBounds = YES;
    }
    return _explainview;
}

@end
