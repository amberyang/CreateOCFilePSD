//
//  YLPSDLayerMask.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDLayerMask.h"
#import "YLDataProcess.h"

@interface YLPSDLayerMask()

@property (nonatomic, strong, readwrite) YLPSDLayerMaskInfo *maskInfo;

@end

@implementation YLPSDLayerMask

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {
    self.startIndex = index;
    
    _maskInfo = [YLPSDLayerMaskInfo new];
    _maskInfo.startIndex = index;
    
    //Size of the data. This will be either 0x14, or zero (in which case the following fields are not present).
    unsigned char maskSize[4] = {0};
    [fileData getBytes:&maskSize range:NSMakeRange(index, sizeof(maskSize))];
    unsigned int layerMaskSize = [YLDataProcess bytesToInt:maskSize length:sizeof(maskSize)];
    NSLog(@"layer mask size is %d", layerMaskSize);
    _maskInfo.size = layerMaskSize;
    
    index += sizeof(maskSize);
    NSInteger maskEndIndex = index + layerMaskSize;
    
    if (layerMaskSize > 0) {
        
        //Rectangle enclosing layer mask
        unsigned char maskTop[4] = {0};
        [fileData getBytes:&maskTop range:NSMakeRange(index, sizeof(maskTop))];
        int layerMaskTop = [YLDataProcess bytesToInt:maskTop length:sizeof(maskTop) sign:YES];
        NSLog(@"layer mask top is %d", layerMaskTop);
        
        index += sizeof(maskTop);
        
        unsigned char maskLeft[4] = {0};
        [fileData getBytes:&maskLeft range:NSMakeRange(index, sizeof(maskLeft))];
        int layerMaskLeft = [YLDataProcess bytesToInt:maskLeft length:sizeof(maskLeft) sign:YES];
        NSLog(@"layer mask left is %d", layerMaskLeft);
        
        index += sizeof(maskLeft);
        
        unsigned char maskBottom[4] = {0};
        [fileData getBytes:&maskBottom range:NSMakeRange(index, sizeof(maskBottom))];
        int layerMaskBottom = [YLDataProcess bytesToInt:maskBottom length:sizeof(maskBottom) sign:YES];
        NSLog(@"layer mask bottom is %d", layerMaskBottom);
        
        index += sizeof(maskBottom);
        
        unsigned char maskRight[4] = {0};
        [fileData getBytes:&maskRight range:NSMakeRange(index, sizeof(maskRight))];
        int layerMaskRight = [YLDataProcess bytesToInt:maskRight length:sizeof(maskRight) sign:YES];
        NSLog(@"layer mask right is %d", layerMaskRight);
        
        index += sizeof(maskRight);
        
        _maskInfo.layerMaskInsets = UIEdgeInsetsMake(layerMaskTop, layerMaskLeft, layerMaskBottom, layerMaskRight);
        
        //0 or 255
        unsigned char color[1] = {0};
        [fileData getBytes:&color range:NSMakeRange(index, sizeof(color))];
        unsigned int defaultColor = [YLDataProcess bytesToInt:color length:sizeof(color)];
        NSLog(@"default color is %d", defaultColor);
        _maskInfo.color = defaultColor;
        
        index += sizeof(color);
        
        //bit 0 = position relative to layer
        //bit 1 = layer mask disabled
        //bit 2 = invert layer mask when blending
        //bit 3 = indicates that the user mask actually came from rendering other data
        //bit 4 = indicates that the user and/or vector masks have parameters applied to them
        unsigned char maskFlag[1] = {0};
        [fileData getBytes:&maskFlag range:NSMakeRange(index, sizeof(maskFlag))];
        unsigned int maskFlags = [YLDataProcess bytesToInt:maskFlag length:sizeof(maskFlag)];
        NSLog(@"mask flag is %d", maskFlags);
        _maskInfo.flags = maskFlags;
        
        index += sizeof(maskFlag);
        
#pragma mark ---- * maybe error
        //Zeros
        unsigned char pad[2] = {0};
        [fileData getBytes:&pad range:NSMakeRange(index, sizeof(pad))];
        unsigned short int padding = [YLDataProcess bytesToInt:pad length:sizeof(pad)];
        NSLog(@"padding is %d", padding);
        
        index += sizeof(pad);
        
    }
        
    if (index != maskEndIndex) {
        NSLog(@"layer mask end index is not match: %ld, %ld",index,maskEndIndex);
        index = maskEndIndex;
    }
        
    _maskInfo.endIndex = index;
    self.endIndex = index;
    return YES;
}

@end
