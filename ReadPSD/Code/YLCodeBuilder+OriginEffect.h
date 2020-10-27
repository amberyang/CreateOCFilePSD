//
//  YLCodeBuilder+OriginEffect.h
//  ReadPSD
//
//  Created by amber on 2020/6/9.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLCodeBuilder.h"

@interface YLCodeBuilder (OriginEffect)

+ (NSString *)addStoke:(YLPSDLayerRecordInfo *)record layer:(CALayer *)layer name:(NSString *)name;

+ (NSString *)setAlpha:(YLPSDLayerRecordInfo *)record layer:(CALayer *)layer name:(NSString *)name;

@end
