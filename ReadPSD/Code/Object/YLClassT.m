//
//  YLClassT.m
//  ReadPSD
//
//  Created by amber on 2020/7/1.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLClassT.h"
#import "YLPropertyT.h"

@implementation YLClassT

- (void)insertProperty:(YLPropertyT *)property {
    if (!property) {
        NSAssert(YES, @"data is not valid");
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (self.properties.count > 0) {
        [array addObjectsFromArray:self.properties];
    }
    if ([array containsObject:property]) {
        NSAssert(YES, @"%@ is exist",property.name);
        return;
    }
    if (array.count == 0) {
        [array addObject:property];
    } else {
        [array insertObject:property atIndex:0];
    }
    self.properties = array;
}

- (YLPropertyT *)getPropertyWithName:(NSString *)name {
    YLPropertyT *property = nil;
    for (YLPropertyT *obj in self.properties) {
        if ([obj.name isEqualToString:name]) {
            property = obj;
            break;
        }
    }
    return property;
}

- (void)insertImportFile:(NSString *)importH {
    __block BOOL isExist = NO;
    [self.importH enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:importH]) {
            isExist = YES;
        }
    }];
    if (!isExist) {
        NSMutableArray *array = [NSMutableArray array];
        if (self.importH.count > 0) {
            [array addObjectsFromArray:self.importH];
        }
        [array addObject:importH];
        self.importH = array;
    }
}

@end
