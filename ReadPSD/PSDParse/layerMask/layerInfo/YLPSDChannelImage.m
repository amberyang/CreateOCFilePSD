//
//  YLPSDChannelImage.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDChannelImage.h"
#import "YLDataProcess.h"
#import "YLRGBA.h"

@implementation YLPSDChannelImage

#pragma mark --- channel image data

+ (NSMutableArray *)channelImageDataForCompression:(NSInteger)compression
                                       channelInfo:(YLPSDChannelInfo *)channelInfo
                                          fileData:(NSData *)fileData
                                         colorMode:(NSInteger)colorMode
                                      currentIndex:(NSInteger)index
                                            offset:(NSInteger)offset
                                              size:(CGSize)size
                                         imageData:(NSMutableArray *)currentData
                                          endIndex:(NSInteger *)endIndex {
    
    NSMutableArray *imageData = [NSMutableArray arrayWithArray:currentData];

    NSInteger count = channelInfo.length;
    NSInteger ciIndex = index + offset;
    NSInteger height = (NSInteger)size.height;
     
    switch (compression) {
        case 0:
        {
            count -= 2;
            if ((int)count > 0) {
//                unsigned int lines[count];
                unsigned int *lines = (unsigned int *)malloc(count * sizeof(unsigned int));
                for (NSInteger k=0; k<count; k++) {
                    unsigned char value[1] = {0};
                    [fileData getBytes:&value range:NSMakeRange(ciIndex, sizeof(value))];
                    unsigned int byteCount = [YLDataProcess bytesToInt:value length:sizeof(value)];
                    lines[k] = byteCount;
                    ciIndex += sizeof(value);
                }
                
                imageData = [[self class] imageDataForData:lines channelInfo:channelInfo colorMode:colorMode size:size imageData:imageData];
                free(lines);
            }
        }
            break;
        case 1:{
            if (count > 2) {

//                unsigned short int linesLength[height];
                unsigned short int *linesLength = (unsigned short int *)malloc(count * sizeof(unsigned short int));
                NSInteger total = 0;
                
                for (NSInteger k=0; k<height; k++) {
                    unsigned char idByteCount[2] = {0};
                    [fileData getBytes:&idByteCount range:NSMakeRange(ciIndex, sizeof(idByteCount))];
                    unsigned short int byteCount = [YLDataProcess bytesToInt:idByteCount length:sizeof(idByteCount)];
//                                NSLog(@"image length is %d", byteCount);
                    linesLength[k] = byteCount;
                    ciIndex += sizeof(idByteCount);
                    total += byteCount;
                }
                
                if (((ciIndex - index) + total) != count) {
                    break;
                }
                
                NSInteger channel_pos = 0;
                NSInteger channelImageLength = size.width * size.height;
//                unsigned int lines[channelImageLength];
                unsigned int *lines = (unsigned int *)malloc(channelImageLength * sizeof(unsigned int));

                for (NSInteger k=0; k<height; k++) {
                    NSInteger currentIndex = ciIndex;
                    unsigned short int byteCount = linesLength[k];
                    while (ciIndex < (currentIndex + byteCount)) {
                        
                        unsigned char ciLen[1] = {0};
                        [fileData getBytes:&ciLen range:NSMakeRange(ciIndex, sizeof(ciLen))];
                        unsigned int cimgLength = [YLDataProcess bytesToInt:ciLen length:sizeof(ciLen)];
                        
                        ciIndex += sizeof(ciLen);
                        
                        if (cimgLength < 128) {
                            cimgLength += 1;
                            for (NSInteger m = 0; m<cimgLength; m++) {
                                unsigned char ciValue[1] = {0};
                                [fileData getBytes:&ciValue range:NSMakeRange(ciIndex, sizeof(ciValue))];
                                unsigned int value = [YLDataProcess bytesToInt:ciValue length:sizeof(ciValue)];
                                lines[channel_pos] = value;
                                channel_pos++;
                                ciIndex += sizeof(ciValue);
                            }
                        } else if (cimgLength > 128) {
                            cimgLength ^= 0xff;
                            cimgLength += 2;
                            unsigned char ciValue[1] = {0};
                            [fileData getBytes:&ciValue range:NSMakeRange(ciIndex, sizeof(ciValue))];
                            unsigned int value = [YLDataProcess bytesToInt:ciValue length:sizeof(ciValue)];
                            ciIndex += sizeof(ciValue);
                            for (NSInteger m = 0; m<cimgLength; m++) {
                                lines[channel_pos] = value;
                                channel_pos++;
                            }
                        }
                    }
                }
                
                free(linesLength);
                
                imageData = [[self class] imageDataForData:lines channelInfo:channelInfo colorMode:colorMode size:size imageData:imageData];
                
                free(lines);

                if (channel_pos != channelImageLength) {
                    NSLog(@"channel image size is not match :%ld, %d",channel_pos, channelInfo.length);
                }
            }
        }
            break;
        default:
            break;
    }
     
    *endIndex = ciIndex;
    return imageData;
}

+ (NSMutableArray *)imageDataForData:(unsigned int *)lines
                         channelInfo:(YLPSDChannelInfo *)channelInfo
                           colorMode:(NSInteger)colorMode
                                size:(CGSize)size
                           imageData:(NSMutableArray *)currentData {
    
    NSMutableArray *imageData = [NSMutableArray arrayWithArray:currentData];
    NSInteger width = (NSInteger)size.width;
    NSInteger height = (NSInteger)size.height;
    switch (colorMode) {
        case 1:
        {

        }
            break;
        case 3:
        {
            for (NSInteger m=0; m<height; m++) {
                for (NSInteger k=0; k<width; k++) {
                    NSInteger currentPoint = m*width+k;
                    
                    YLRGBA *rgba = [YLRGBA new];
                    if (imageData.count > currentPoint) {
                        rgba = [imageData objectAtIndex:currentPoint];
                    }
                    unsigned int value = lines[currentPoint];
                    switch (channelInfo.channelId) {
                        case -1:
                        {
                            rgba.alpha = value;
                        }
                            break;
                        case 0:
                        {
                            rgba.red = value;
                        }
                            break;
                        case 1:
                        {
                            rgba.green = value;
                        }
                            break;
                        case 2:
                        {
                            rgba.blue = value;
                        }
                            break;
                        case -2:
                        {
                            rgba.mask = value;
//                            NSLog(@"-2: %d",value);
                        }
                            break;
                        case -3:
                        {
//                            NSLog(@"-3: %d",value);
                        }
                        default:
                            break;
                    }
                    
                    if (imageData.count < currentPoint) {
                        [imageData addObject:rgba];
                    }
                }
            }
        }
            break;
        case 4:
        {

        }
            break;
        default:
            break;
    }
    return imageData;
}

@end
