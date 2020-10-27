//
//  YLPSDLayerAndMask.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDLayerAndMask.h"
#import "YLDataProcess.h"
#import "YLPSDLayerInfo.h"
#import "YLPSDGlobalLayerMask.h"
#import "YLPSDAdditionalLayer.h"

@interface YLPSDLayerAndMask()

@property (nonatomic, strong, readwrite) YLPSDLayerAndMaskInfo *layerMaskInfo;

@end

@implementation YLPSDLayerAndMask

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index channel:(unsigned int)channel colorMode:(NSInteger)colorMode {

    self.startIndex = index;
    
    _layerMaskInfo = [YLPSDLayerAndMaskInfo new];
    _layerMaskInfo.startIndex = index;
    
#pragma mark ------ layer and mask information
    
    //Length of the miscellaneous information section.
    unsigned char lmLength[4] = {0};
    [fileData getBytes:&lmLength range:NSMakeRange(index, sizeof(lmLength))];
    unsigned int layerMaskLength = [YLDataProcess bytesToInt:lmLength length:sizeof(lmLength)];
    NSLog(@"layer and mask length is %d", layerMaskLength);
    _layerMaskInfo.length = layerMaskLength;
    
    index += sizeof(lmLength);
    NSInteger endIndex = index + layerMaskLength;
    
    YLPSDLayerInfo *layerInfo = [YLPSDLayerInfo new];
    [layerInfo parse:fileData index:index channel:channel colorMode:colorMode];
    index = layerInfo.endIndex;
    _layerMaskInfo.layerInfos = layerInfo.layerInfo;
   
#pragma mark --- global mask layer info
    YLPSDGlobalLayerMask *globalLayerMask = [YLPSDGlobalLayerMask new];
    [globalLayerMask parse:fileData index:index];
    index = globalLayerMask.endIndex;
    _layerMaskInfo.globalLayerMask = globalLayerMask.globalLayerMask;
    
#pragma mark --- additional layer info
    NSMutableArray *array = [NSMutableArray array];
    while (index < endIndex) {
        YLPSDAdditionalLayer *adjustmentLayer = [YLPSDAdditionalLayer new];
        [adjustmentLayer parse:fileData index:index record:nil];
        [array addObject:adjustmentLayer.adjustment];
        index = adjustmentLayer.endIndex;
    }
    _layerMaskInfo.adjustmentLayers = array;
    
    if (endIndex != index) {
        index = endIndex;
        NSLog(@"layer mask length and layer info is not match: %ld, %ld",endIndex,index);
    }
    
    self.endIndex = index;
    return YES;
}

@end
