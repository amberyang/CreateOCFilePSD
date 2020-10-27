//
//  YLMethodManager+Layout.h
//  ReadPSD
//
//  Created by amber on 2020/6/19.
//  Copyright © 2020 amber. All rights reserved.
//


#import "YLMethodManager.h"

@interface YLMethodManager (Layout)

+ (NSArray<NSString *> *)removeDuplicates:(NSString *)content array:(NSArray<NSString *> *)array;

+ (NSArray<YLPropertyT *> *)adjustLayoutRelation:(YLPSDLayerRecordInfo *)record;

+ (NSArray<YLPropertyT *> *)adjustTop:(NSArray<YLPropertyT *> *)properties
                             frameDic:(NSDictionary<NSString *, NSValue *> *)frameDic
                                regex:(NSRegularExpression *)regex
                            sizeRegex:(NSRegularExpression *)sizeRegex;

+ (NSArray<YLPropertyT *> *)adjustLeft:(NSArray<YLPropertyT *> *)properties
                              frameDic:(NSDictionary<NSString *, NSValue *> *)frameDic
                                 regex:(NSRegularExpression *)regex
                             sizeRegex:(NSRegularExpression *)sizeRegex;

@end
