//
//  Explainviewm
//  workspace
//
//  Created by  on 2020/08/06.
//  Copyright © 202年 . All rights reserved.
//


#import "Explainview.h"


@interface Explainview()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *canceltext;
@end

@implementation Explainview

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
    [self addSubview:self.icon];
    UIImage *image = [UIImage imageNamed:@"icon.png"];
    self.icon.image = image;
    
    //----------------
    [self addSubview:self.canceltext];
    [self.canceltext setText:@"取消规则"];
    
    [self setNeedsLayout];
 }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    //----------------
    CGSize canceltext_size = [_canceltext sizeThatFits:CGSizeMake(45.0, CGFLOAT_MAX)];
    
    //----------------
    totalHeight += MAX(17.0, canceltext_size.height);
    
    
    return CGSizeMake(size.width, totalHeight);
}

- (void)p_layout {
    //----------------
    [_icon setFrame:CGRectMake(0.0, 0.0, 17.0, CGRectGetHeight(self.frame))];
    
    //----------------
    _canceltext.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    CGSize canceltext_size = [_canceltext sizeThatFits:CGSizeMake(45.0, CGFLOAT_MAX)];
    [_canceltext setFrame:CGRectMake(CGRectGetMaxX(_icon.frame) + 4.0, (CGRectGetMinY(_icon.frame)+(CGRectGetHeight(_icon.frame)-ceil(canceltext_size.height))/2), ceil(canceltext_size.width), ceil(canceltext_size.height))];
    
}

#pragma mark ---- init

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        [_icon setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _icon;
}

- (UILabel *)canceltext {
    if (!_canceltext) {
        _canceltext = [[UILabel alloc] init];
        [_canceltext setTextAlignment:NSTextAlignmentLeft];
        [_canceltext setTextColor:[UIColor colorWithWhite:153/255.0 alpha:255/255.0]];
        [_canceltext setFont:[UIFont systemFontOfSize:ceil(12.0)]];
        _canceltext.adjustsFontSizeToFitWidth = YES;
    }
    return _canceltext;
}

@end