//
//  YLPSDLayerRecordInfo.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDBaseSection.h"
#import "YLPSDChannelInfo.h"
#import "YLPascalString.h"
#import "YLPSDAdditionalLayerInfo.h"
#import "YLPSDLayerMaskInfo.h"
#import "YLPSDLayerBlendRangeInfo.h"
#import "YLBGRGBA.h"
#import "YLClassT.h"

@interface YLPSDLayerRecordInfo : YLPSDBaseSection

@property (nonatomic, assign) UIEdgeInsets layerInsets;
@property (nonatomic, assign) UIEdgeInsets originLayerInsets;
@property (nonatomic, assign) unsigned short int channelCount;
@property (nonatomic, strong) NSArray<YLPSDChannelInfo *> *channelInfos;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *modeKey;
@property (nonatomic, assign) unsigned int opacity;
@property (nonatomic, assign) unsigned short int clipping;
@property (nonatomic, assign) unsigned short int flags;
@property (nonatomic, assign) unsigned short int filler;
@property (nonatomic, assign) unsigned int length;
@property (nonatomic, strong) YLPSDLayerMaskInfo *layerMask;
@property (nonatomic, strong) YLPSDLayerBlendRangeInfo *blendRange;
@property (nonatomic, strong) YLPascalString *name;
@property (nonatomic, strong) NSDictionary<NSString *, YLPSDAdditionalLayerInfo *> *adjustments;
@property (nonatomic, assign) unsigned int layerType;
@property (nonatomic, assign) unsigned short int compression;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL hasMask;
@property (nonatomic, strong) YLBGRGBA *bgColor;
@property (nonatomic, strong) NSArray<YLPSDLayerRecordInfo *> *records;
@property (nonatomic, weak) YLPSDLayerRecordInfo *parentRecord;
@property (nonatomic, assign) unsigned int layer_id;

@property (nonatomic, strong) YLClassT *classObj;
@property (nonatomic, strong) UIView *classView;
@property (nonatomic, strong) NSDictionary<NSString *, UIImage *> *imageDic;

- (void)updateChildEffect;
- (YLRGBA *)getOverlayRGBA:(NSInteger *)index;
- (YLGradient *)getOverlayGradient:(NSInteger *)index;

@end
