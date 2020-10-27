//
//  YLPSDLayerRecord.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDLayerRecord.h"
#import "YLDataProcess.h"
#import "YLPSDChannel.h"
#import "YLPSDLayerMask.h"
#import "YLPSDLayerBlendRange.h"
#import "YLPSDAdditionalLayer.h"
#import "YLFileProcess.h"

@interface YLPSDLayerRecord()

@property (nonatomic, strong, readwrite) YLPSDLayerRecordInfo *record;

@end

@implementation YLPSDLayerRecord

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {
    self.startIndex = index;
    
#pragma mark ------ layer record
    _record = [YLPSDLayerRecordInfo new];
    _record.startIndex = index;
    
    //The rectangle containing the contents of the layer.
    unsigned char lyrTop[4] = {0};
    [fileData getBytes:&lyrTop range:NSMakeRange(index, sizeof(lyrTop))];
    int layerTop = [YLDataProcess bytesToInt:lyrTop length:sizeof(lyrTop) sign:YES];
    NSLog(@"layer top is %d", layerTop);
    
    index += sizeof(lyrTop);
    
    unsigned char lyrLeft[4] = {0};
    [fileData getBytes:&lyrLeft range:NSMakeRange(index, sizeof(lyrLeft))];
    int layerLeft = [YLDataProcess bytesToInt:lyrLeft length:sizeof(lyrLeft) sign:YES];
    NSLog(@"layer left is %d", layerLeft);
    
    index += sizeof(lyrLeft);
    
    unsigned char lyrBottom[4] = {0};
    [fileData getBytes:&lyrBottom range:NSMakeRange(index, sizeof(lyrBottom))];
    int layerBottom = [YLDataProcess bytesToInt:lyrBottom length:sizeof(lyrBottom) sign:YES];
    NSLog(@"layer bottom is %d", layerBottom);
    
    index += sizeof(lyrBottom);
    
    unsigned char lyrRight[4] = {0};
    [fileData getBytes:&lyrRight range:NSMakeRange(index, sizeof(lyrRight))];
    int layerRight = [YLDataProcess bytesToInt:lyrRight length:sizeof(lyrRight) sign:YES];
    NSLog(@"layer right is %d", layerRight);
    
    index += sizeof(lyrRight);
    
    _record.layerInsets = UIEdgeInsetsMake(layerTop, layerLeft, layerBottom, layerRight);
    _record.originLayerInsets = UIEdgeInsetsMake(layerTop, layerLeft, layerBottom, layerRight);
        
    //he number of channels in the layer.
    unsigned char channelNum[2] = {0};
    [fileData getBytes:&channelNum range:NSMakeRange(index, sizeof(channelNum))];
    unsigned short int numChannel = [YLDataProcess bytesToInt:channelNum length:sizeof(channelNum)];
    NSLog(@"channels number in the layer is %d", numChannel);
    _record.channelCount = numChannel;
    
    index += sizeof(channelNum);
    
    NSInteger channelEndIndex = index + (6 * numChannel);

#pragma mark ------ #layer channels
    //Channel information. This contains a six byte record for each channel
    //ix bytes per channel, consisting of:
    //2 bytes for Channel ID: 0 = red, 1 = green, etc.;
    //-1 = transparency mask; -2 = user supplied layer mask, -3 real user supplied layer mask
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger k=0; k<numChannel; k++) {
        YLPSDChannel *channel = [YLPSDChannel new];
        [channel parse:fileData index:index];
        [array addObject:channel.channelInfo];
        index = channel.endIndex;
    }
    _record.channelInfos = array;
    
    if (channelEndIndex != index) {
        index = channelEndIndex;
        NSLog(@"channel end index is not match: %ld, %ld",channelEndIndex, index);
    }
    
    //Always 8BIM.
    unsigned char signature[4] = {0};
    [fileData getBytes:&signature range:NSMakeRange(index, sizeof(signature))];
    NSData *data = [NSData dataWithBytes:signature length:sizeof(signature)];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"blend mode signature is %@", string);
    _record.signature = string;
    
    index += sizeof(signature);
    
    //'norm' = normal 'dark' = darken 'lite' = lighten 'hue ' = hue
    //'sat ' = saturation 'colr' = color
    //'lum ' = luminosity 'mul ' = multiply 'scrn' = screen 'diss' = dissolve 'over' = overlay 'hLit' = hard light 'sLit' = soft light 'diff' = difference
    unsigned char modeKey[4] = {0};
    [fileData getBytes:&modeKey range:NSMakeRange(index, sizeof(modeKey))];
    data = [NSData dataWithBytes:modeKey length:sizeof(modeKey)];
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"blend mode key is %@", string);
    _record.modeKey = string;
    
    index += sizeof(modeKey);
    
    //0 = transparent ... 255 = opaque
    unsigned char opacity[1] = {0};
    [fileData getBytes:&opacity range:NSMakeRange(index, sizeof(opacity))];
    unsigned int layerOpacity = [YLDataProcess bytesToInt:opacity length:sizeof(opacity)];
    NSLog(@"opacity is %d", layerOpacity);
    _record.opacity = layerOpacity;
    
    index += sizeof(opacity);
    
    //0 = base, 1 = non–base
    unsigned char clipping[1] = {0};
    [fileData getBytes:&clipping range:NSMakeRange(index, sizeof(clipping))];
    unsigned short int layerClipping = [YLDataProcess bytesToInt:clipping length:sizeof(clipping)];
    NSLog(@"clipping is %d", layerClipping);
    _record.clipping = layerClipping;
    
    index += sizeof(clipping);
    
    //bit 0 = transparency protected;
    //bit 1 = visible;
    //bit 2 = obsolete;
    //bit 3 = 1 for Photoshop 5.0 and later, tells if bit 4 has useful information;
    //bit 4 = pixel data irrelevant to appearance of document
    unsigned char flags[1] = {0};
    [fileData getBytes:&flags range:NSMakeRange(index, sizeof(flags))];
    unsigned short int layerFlags = [YLDataProcess bytesToInt:flags length:sizeof(flags)];
    NSLog(@"flags is %d", layerFlags);
    _record.flags = layerFlags;
    
    index += sizeof(flags);
    
    //(zero)
    unsigned char filler[1] = {0};
    [fileData getBytes:&filler range:NSMakeRange(index, sizeof(filler))];
    unsigned short int layerFiller = [YLDataProcess bytesToInt:filler length:sizeof(filler)];
    NSLog(@"filler is %d", layerFiller);
    _record.filler = layerFiller;
    
    index += sizeof(filler);
    
    //Length of the extra data field. This is the total length of the next five fields.
    unsigned char extra[4] = {0};
    [fileData getBytes:&extra range:NSMakeRange(index, sizeof(extra))];
    unsigned int extraDataSize = [YLDataProcess bytesToInt:extra length:sizeof(extra)];
    NSLog(@"extra data size is %d", extraDataSize);
    _record.length = extraDataSize;
    
    index += sizeof(extra);
    NSInteger endIndex = index + extraDataSize;
    
#pragma mark ------ #layer mask
    //Size of the data. This will be either 0x14, or zero (in which case the following fields are not present).
    YLPSDLayerMask *layerMask = [YLPSDLayerMask new];
    [layerMask parse:fileData index:index];
    index = layerMask.endIndex;
    _record.layerMask = layerMask.maskInfo;

#pragma mark ------ #layer blending ranges data
    //Length of layer blending ranges data
    YLPSDLayerBlendRange *blendRange = [YLPSDLayerBlendRange new];
    [blendRange parse:fileData index:index];
    index = blendRange.endIndex;
    _record.blendRange = blendRange.blendInfo;
    
    YLPascalString *name = [YLPascalString new];
    
    unsigned char a[200] = {0};
    [fileData getBytes:&a range:NSMakeRange(index, MIN(200, fileData.length - index))];
    
    unsigned char nameLength[1] = {0};
    [fileData getBytes:&nameLength range:NSMakeRange(index, sizeof(nameLength))];
    unsigned int layerNameLength = [YLDataProcess bytesToInt:nameLength length:sizeof(nameLength)];
    layerNameLength = ((layerNameLength + 4) & ~0x03) - 1;
    if (layerNameLength <= 0) {
        layerNameLength = 3;
    }
    NSLog(@"layer name length is %d", layerNameLength);
    name.length = layerNameLength;
    
    index += sizeof(nameLength);
    
    data = [fileData subdataWithRange:NSMakeRange(index, layerNameLength)];
    string = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    NSLog(@"layer name is %@", string);
    name.text = string;
    _record.name = name;
    
    index += layerNameLength;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    while (index < endIndex) {
        YLPSDAdditionalLayer *additional = [YLPSDAdditionalLayer new];
        [additional parse:fileData index:index record:_record];
        index = additional.endIndex;
        [dic setObject:additional.adjustment forKey:additional.adjustment.key];
        
        if ([@"lyid" isEqualToString:additional.adjustment.key]) {
            _record.layer_id = [[[additional.adjustment.result objectForKey:@"lyid"] objectForKey:@"layer_id"] intValue];
        }
    }
    
    _record.adjustments = dic;
    
    if (index != endIndex) {
        NSLog(@"record end index is not match: %ld, %ld",index,endIndex);
        index = endIndex;
    }
        
    _record.endIndex = index;
    self.endIndex = index;
    return YES;
}

@end
