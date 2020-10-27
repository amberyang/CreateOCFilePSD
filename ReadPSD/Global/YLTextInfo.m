//
//  YLTextInfo.m
//  ReadPSD
//
//  Created by amber on 2019/10/9.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLTextInfo.h"

@implementation YLTextInfo

+ (NSArray<YLTextInfo *> *)mergeAttr:(NSArray<YLTextInfo *> *)array {
    if (array.count == 1) {
        return array;
    }
    NSMutableArray<YLTextInfo *> *styles = [NSMutableArray array];
    YLTextInfo *obj = nil;
    for (YLTextInfo *textInfo in array) {
        if (obj == nil) {
            obj = [textInfo copy];
        } else if ([obj isEqualStyle:textInfo]) {
            if (obj.autoKerning != textInfo.autoKerning) {
                obj.autoKerning = YES;
            }
            if ((obj.startIndex + obj.textLength) == textInfo.startIndex) {
                obj.textLength += textInfo.textLength;
            } else {
                [styles addObject:obj];
                obj = textInfo;
            }
        } else {
            [styles addObject:obj];
            obj = textInfo;
        }
    }
    if (styles.count == 0 && obj) {
        [styles addObject:obj];
    }
    return styles;
}

- (BOOL)isEqualStyle:(YLTextInfo *)info {
    if (info.isBold != self.isBold) {
        return NO;
    }
    if (info.isItalic != self.isItalic) {
        return NO;
    }
    if (info.leading != self.leading) {
        return NO;
    }
    if (info.fontSize != self.fontSize) {
        return NO;
    }
    if (info.alignment != self.alignment) {
        return NO;
    }
    if (info.fontName && ![info.fontName isEqualToString:self.fontName]) {
        return NO;
    }
    if (![info.fillColor isEqual:self.fillColor]) {
        return NO;
    }
    if (![info.stokeColor isEqual:self.stokeColor]) {
        return NO;
    }
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    YLTextInfo *copyObj = [YLTextInfo new];
    copyObj.isBold = self.isBold;
    copyObj.isItalic = self.isItalic;
    copyObj.autoKerning = self.autoKerning;
    copyObj.fillColor = [self.fillColor copy];
    copyObj.stokeColor = [self.stokeColor copy];
    copyObj.alignment = self.alignment;
    copyObj.fontName = self.fontName;
    copyObj.leading = self.leading;
    copyObj.fontSize = self.fontSize;
    copyObj.text = self.text;
    copyObj.textLength = self.textLength;
    return copyObj;
}

@end
