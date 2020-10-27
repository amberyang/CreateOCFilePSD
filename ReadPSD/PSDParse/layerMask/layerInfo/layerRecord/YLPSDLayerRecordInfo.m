//
//  YLPSDLayerRecordInfo.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDLayerRecordInfo.h"

@implementation YLPSDLayerRecordInfo

- (void)updateChildEffect {
    for (YLPSDLayerRecordInfo *child in self.records) {
        child.parentRecord = self;
        [child updateChildEffect];
    }
}

- (YLGradient *)getOverlayGradient:(NSInteger *)index {
    YLGradient *gradient = self.bgColor.effect.gradient;
    NSInteger temp = 0;
    if (gradient && index) {
        (*index)++;
        temp++;
    }
    YLPSDLayerRecordInfo *parentRecord = self.parentRecord;
    while (parentRecord) {
        temp++;
        if (parentRecord.bgColor.effect.gradient) {
            gradient = parentRecord.bgColor.effect.gradient;
            *index = temp;
        }
        parentRecord = parentRecord.parentRecord;
    }
    return gradient;
}

- (YLRGBA *)getOverlayRGBA:(NSInteger *)index {
    YLRGBA *rgba = self.bgColor.effect.rgba;
    NSInteger temp = 0;
    if (rgba && index) {
        (*index)++;
        temp++;
    }
    YLPSDLayerRecordInfo *parentRecord = self.parentRecord;
    while (parentRecord) {
        temp++;
        if (parentRecord.bgColor.effect.rgba) {
            rgba = parentRecord.bgColor.effect.rgba;
            *index = temp;
        }
        parentRecord = parentRecord.parentRecord;
    }
    return rgba;
}

@end
