//
//  YLTextInfo.h
//  ReadPSD
//
//  Created by amber on 2019/10/9.
//  Copyright © 2019 amber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLRGBA.h"

@interface YLTextInfo : NSObject<NSCopying>

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) float leading;
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSArray<YLTextInfo *> *> *styles;


@property (nonatomic, assign) BOOL isBold;
@property (nonatomic, assign) BOOL isItalic;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) BOOL autoKerning;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) NSInteger alignment;
@property (nonatomic, strong) YLRGBA *fillColor;
@property (nonatomic, strong) YLRGBA *stokeColor;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) NSInteger textLength;

+ (NSArray<YLTextInfo *> *)mergeAttr:(NSArray<YLTextInfo *> *)array;

@end
