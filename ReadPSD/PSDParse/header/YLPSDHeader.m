//
//  YLPSDHeader.m
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDHeader.h"
#import "YLDataProcess.h"

@interface YLPSDHeader()

@property (nonatomic, strong, readwrite) YLPSDHeaderInfo *headerInfo;

@end

@implementation YLPSDHeader

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {
    
    self.startIndex = index;
    
    const void *header = [fileData bytes];
    NSString *string = [NSString stringWithUTF8String:header];
    //Always equal to 8BPS. Do not try to read the file if the signature does not match this value.
    if (![string isEqualToString:@"8BPS"]) {
        return NO;
    }
    
    _headerInfo = [YLPSDHeaderInfo new];
    _headerInfo.startIndex = index;
            
    unsigned char type[4] = {0};
    [fileData getBytes:&type range:NSMakeRange(0, sizeof(type))];
    NSData *data = [NSData dataWithBytes:type length:sizeof(type)];
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"type is %@", string);
    _headerInfo.signature = string;

    index += sizeof(type);

    //Always equal to 8BPS. Do not try to read the file if the signature does not match this value.
    if (![string isEqualToString:@"8BPS"]) {
        return NO;
    }
        
    unsigned char version[2] = {0};
    [fileData getBytes:&version range:NSMakeRange(index, sizeof(version))];
//    data = [NSData dataWithBytes:version length:sizeof(version)];
    unsigned short int versionid = [YLDataProcess bytesToInt:version length:sizeof(version)];
    NSLog(@"version id is %d", versionid);
    _headerInfo.version = versionid;

    index += sizeof(version);
    //Always equal to 1. Do not try to read the file if the version does not match this value
    if (versionid != 1) {
        return NO;
    }
    
    unsigned char reserved[6] = {0};
    [fileData getBytes:&reserved range:NSMakeRange(index, sizeof(reserved))];
//    data = [NSData dataWithBytes:reserved length:sizeof(reserved)];
    unsigned int reserve = [YLDataProcess bytesToInt:reserved length:sizeof(reserved)];
    NSLog(@"reserved is %d", reserve);
    _headerInfo.reserved = reserve;

    index += sizeof(reserved);
    // Must be zero
    if (reserve != 0) {
        return NO;
    }
    
    //The number of channels in the image, including any alpha chan- nels. Supported range is 1 to 24.
    unsigned char channels[2] = {0};
    [fileData getBytes:&channels range:NSMakeRange(index, sizeof(channels))];
    unsigned short int channel = [YLDataProcess bytesToInt:channels length:sizeof(channels)];
    NSLog(@"channels is %d", channel);
    _headerInfo.channels = channel;

    index += sizeof(channels);

    //The height of the image in pixels. Supported range is 1 to 30,000.
    unsigned char rows[4] = {0};
    [fileData getBytes:&rows range:NSMakeRange(index, sizeof(rows))];
    unsigned int height = [YLDataProcess bytesToInt:rows length:sizeof(rows)];
    NSLog(@"image height is %d", height);
    _headerInfo.height = height;
    
    index += sizeof(rows);
    
    //The width of the image in pixels. Supported range is 1 to 30,000.
    unsigned char columns[4] = {0};
    [fileData getBytes:&columns range:NSMakeRange(index, sizeof(columns))];
    unsigned int width = [YLDataProcess bytesToInt:columns length:sizeof(columns)];
    NSLog(@"image width is %d", width);
    _headerInfo.width = width;
    
    index += sizeof(columns);
        
    //The number of bits per channel. Supported values are 1, 8, and 16.
    unsigned char depth[2] = {0};
    [fileData getBytes:&depth range:NSMakeRange(index, sizeof(depth))];
    unsigned short int colorDepth = [YLDataProcess bytesToInt:depth length:sizeof(depth)];
    NSLog(@"color depth is %d", colorDepth);
    _headerInfo.depth = colorDepth;

    index += sizeof(depth);
    
    //The color mode of the file. Supported values are: Bitmap=0; Grayscale=1; Indexed=2; RGB=3; CMYK=4; Multichannel=7; Duotone=8; Lab=9.
    unsigned char mode[2] = {0};
    [fileData getBytes:&mode range:NSMakeRange(index, sizeof(mode))];
    unsigned short int colorMode = [YLDataProcess bytesToInt:mode length:sizeof(mode)];
    NSLog(@"color mode is %d", colorMode);
    _headerInfo.colorMode = colorMode;

    index += sizeof(mode);
    
    _headerInfo.endIndex = index;
    self.endIndex = index;
    return YES;
}

@end
