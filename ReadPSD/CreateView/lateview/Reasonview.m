//
//  Reasonviewm
//  workspace
//
//  Created by  on 2020/08/06.
//  Copyright © 202年 . All rights reserved.
//


#import "Reasonview.h"
#import "Cancelview.h"


@interface Reasonview()

@property (nonatomic, strong) Cancelview *cancelview;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *reasontext;
@end

@implementation Reasonview

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
    [self addSubview:self.cancelview];
    
    //----------------
    [self addSubview:self.title];
    [self.title setText:@"抱歉，司机迟到了\r您可以免费取消订单"];
    NSMutableAttributedString *title_attr = [[NSMutableAttributedString alloc] initWithString:@"抱歉，司机迟到了\r您可以免费取消订单"];
    NSMutableParagraphStyle *title_paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [title_paragraphStyle setLineSpacing:9.0];
    [title_paragraphStyle setAlignment:NSTextAlignmentCenter];
    [title_attr addAttribute:NSParagraphStyleAttributeName value:title_paragraphStyle range:NSMakeRange(0, 18)];
    [title_attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:ceil(17.0)] range:NSMakeRange(0, 18)];
    [title_attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:51/255.0 alpha:255/255.0] range:NSMakeRange(0, 18)];
    [self.title setAttributedText:title_attr];
    
    //----------------
    [self addSubview:self.reasontext];
    [self.reasontext setText:@"这已是离您最近的司机啦！为避免影响您的信誉\r若为司机的责任，请让司机取消"];
    NSMutableAttributedString *reasontext_attr = [[NSMutableAttributedString alloc] initWithString:@"这已是离您最近的司机啦！为避免影响您的信誉\r若为司机的责任，请让司机取消"];
    NSMutableParagraphStyle *reasontext_paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [reasontext_paragraphStyle setLineSpacing:11.0];
    [reasontext_paragraphStyle setAlignment:NSTextAlignmentCenter];
    [reasontext_attr addAttribute:NSParagraphStyleAttributeName value:reasontext_paragraphStyle range:NSMakeRange(0, 36)];
    [reasontext_attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:ceil(15.0)] range:NSMakeRange(0, 12)];
    [reasontext_attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:51/255.0 alpha:255/255.0] range:NSMakeRange(0, 12)];
    [reasontext_attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:ceil(15.0)] range:NSMakeRange(12, 10)];
    [reasontext_attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:153/255.0 alpha:255/255.0] range:NSMakeRange(12, 10)];
    [self.reasontext setAttributedText:reasontext_attr];
    
    [self setNeedsLayout];
 }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    //----------------
    CGSize cancelview_size = [_cancelview sizeThatFits:CGSizeMake((CGRectGetWidth(self.frame) - (2 * 113.0)), CGFLOAT_MAX)];
    totalHeight += ceil(cancelview_size.height);
    
    //----------------
    CGSize title_size = [_title sizeThatFits:CGSizeMake((CGRectGetWidth(self.frame) - (2 * 78.0)), CGFLOAT_MAX)];
    totalHeight += (17.0 + ceil(title_size.height));
    
    //----------------
    CGSize reasontext_size = [_reasontext sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX)];
    totalHeight += (9.0 + ceil(reasontext_size.height));
    
    
    return CGSizeMake(size.width, totalHeight);
}

- (void)p_layout {
    //----------------
    CGSize cancelview_size = [_cancelview sizeThatFits:CGSizeMake((CGRectGetWidth(self.frame) - (2 * 113.0)), CGFLOAT_MAX)];
    [_cancelview setFrame:CGRectMake(((CGRectGetWidth(self.frame) - ceil(cancelview_size.width))/2), 0.0, ceil(cancelview_size.width), ceil(cancelview_size.height))];
    
    //----------------
    CGSize title_size = [_title sizeThatFits:CGSizeMake((CGRectGetWidth(self.frame) - (2 * 78.0)), CGFLOAT_MAX)];
    [_title setFrame:CGRectMake(((CGRectGetWidth(self.frame)-ceil(title_size.width))/2), (CGRectGetMaxY(_cancelview.frame)+17.0), ceil(title_size.width), ceil(title_size.height))];
    _title.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    
    //----------------
    CGSize reasontext_size = [_reasontext sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX)];
    [_reasontext setFrame:CGRectMake(((CGRectGetWidth(self.frame)-ceil(reasontext_size.width))/2), (CGRectGetMaxY(_title.frame)+9.0), ceil(reasontext_size.width), ceil(reasontext_size.height))];
    _reasontext.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    
}

#pragma mark ---- init

- (Cancelview *)cancelview {
    if (!_cancelview) {
        _cancelview = [[Cancelview alloc] init];
        [_cancelview.layer setOpacity:0.3];
        _cancelview.clipsToBounds = YES;
    }
    return _cancelview;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        [_title setTextAlignment:NSTextAlignmentCenter];
        _title.adjustsFontSizeToFitWidth = YES;
        [_title setLineBreakMode:NSLineBreakByCharWrapping];
        [_title setNumberOfLines:0];
    }
    return _title;
}

- (UILabel *)reasontext {
    if (!_reasontext) {
        _reasontext = [[UILabel alloc] init];
        [_reasontext setTextAlignment:NSTextAlignmentCenter];
        _reasontext.adjustsFontSizeToFitWidth = YES;
        [_reasontext setLineBreakMode:NSLineBreakByCharWrapping];
        [_reasontext setNumberOfLines:0];
    }
    return _reasontext;
}

@end
