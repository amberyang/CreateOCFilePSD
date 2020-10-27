//
//  YLPropertyT.m
//  ReadPSD
//
//  Created by amber on 2020/7/1.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLPropertyT.h"

@implementation YLPropertyT

- (BOOL)isEqual:(id)object {
    BOOL isEqual = [super isEqual:object];
    if (!isEqual) {
        if ([object isKindOfClass:[YLPropertyT class]]) {
            YLPropertyT *obj = (YLPropertyT *)object;
            isEqual = ([obj.name isEqual:self.name] && [obj.propertyClass isEqual:self.propertyClass]);
        }
    }
    return isEqual;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    YLPropertyT *copyObj = [YLPropertyT new];
    copyObj.initial = self.initial;
    if (self.layout.count > 0) {
        copyObj.layout = [[NSMutableArray alloc] initWithArray:self.layout copyItems:YES];
    }
    copyObj.name = self.name;
    copyObj.propertyClass = self.propertyClass;
    copyObj.value = self.value;
    copyObj.calculateSize = self.calculateSize;
    return copyObj;
}

@end
