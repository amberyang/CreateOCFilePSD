//
//  YLPSDLayerBlendRange.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDLayerBlendRange.h"
#import "YLDataProcess.h"
#import "YLFileProcess.h"

@interface YLPSDLayerBlendRange()

@property (nonatomic, strong, readwrite) YLPSDLayerBlendRangeInfo *blendInfo;

@end

@implementation YLPSDLayerBlendRange

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {
    self.startIndex = index;
    
    _blendInfo = [YLPSDLayerBlendRangeInfo new];
    _blendInfo.startIndex = index;
    
#pragma mark ------ #layer blending ranges data
    //Length of layer blending ranges data
    unsigned char lbrLength[4] = {0};
    [fileData getBytes:&lbrLength range:NSMakeRange(index, sizeof(lbrLength))];
    unsigned int layerBlendLength = [YLDataProcess bytesToInt:lbrLength length:sizeof(lbrLength)];
    NSLog(@"layer blending rangs data length is %d", layerBlendLength);
    _blendInfo.length = layerBlendLength;
    
    NSInteger endIndex = index + sizeof(lbrLength) + layerBlendLength;
    index += sizeof(lbrLength);
    
    unsigned int source_black1 = [YLFileProcess getByteFromFile:fileData index:&index];
    unsigned int source_black2 = [YLFileProcess getByteFromFile:fileData index:&index];

    unsigned int source_white1 = [YLFileProcess getByteFromFile:fileData index:&index];
    unsigned int source_white2 = [YLFileProcess getByteFromFile:fileData index:&index];
    
    //Composite gray blend source. Contains 2 black values followed by 2 white values. Present but irrelevant for Lab & Grayscale.
    NSLog(@"gray blend source : %d,%d,%d,%d",source_black1,source_black2,source_white1,source_white2);
    
    unsigned int dest_black1 = [YLFileProcess getByteFromFile:fileData index:&index];
    unsigned int dest_black2 = [YLFileProcess getByteFromFile:fileData index:&index];

    unsigned int dest_white1 = [YLFileProcess getByteFromFile:fileData index:&index];
    unsigned int dest_white2 = [YLFileProcess getByteFromFile:fileData index:&index];
    
    //Composite gray blend destination range.
    NSLog(@"gray blend destination range : %d,%d,%d,%d",dest_black1,dest_black2,dest_white1,dest_white2);
    
    NSInteger num_channels = (layerBlendLength - 8)/8;
    
    for (NSInteger i=0; i<num_channels; i++) {
        unsigned int channel_source_black1 = [YLFileProcess getByteFromFile:fileData index:&index];
        unsigned int channel_source_black2 = [YLFileProcess getByteFromFile:fileData index:&index];

        unsigned int channel_source_white1 = [YLFileProcess getByteFromFile:fileData index:&index];
        unsigned int channel_source_white2 = [YLFileProcess getByteFromFile:fileData index:&index];
        
        //Composite gray blend source. Contains 2 black values followed by 2 white values. Present but irrelevant for Lab & Grayscale.
        NSLog(@"gray blend source : %d,%d,%d,%d",channel_source_black1,channel_source_black2,channel_source_white1,channel_source_white2);
        
        unsigned int channel_dest_black1 = [YLFileProcess getByteFromFile:fileData index:&index];
        unsigned int channel_dest_black2 = [YLFileProcess getByteFromFile:fileData index:&index];

        unsigned int channel_dest_white1 = [YLFileProcess getByteFromFile:fileData index:&index];
        unsigned int channel_dest_white2 = [YLFileProcess getByteFromFile:fileData index:&index];
        
        //Composite gray blend destination range.
        NSLog(@"gray blend destination range : %d,%d,%d,%d",channel_dest_black1,channel_dest_black2,channel_dest_white1,channel_dest_white2);
    }
    
    if (index != endIndex) {
        NSLog(@"blend range length is not match: %ld, %ld",index,endIndex);
    }
    
    _blendInfo.endIndex = endIndex;
    self.endIndex = index;
    return YES;
}

@end
