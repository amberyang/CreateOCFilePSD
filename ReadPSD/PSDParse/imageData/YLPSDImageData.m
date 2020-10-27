//
//  YLPSDImageData.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDImageData.h"
#import "YLDataProcess.h"
#import "YLPSDChannelInfo.h"
#import "YLPSDChannelImage.h"
#import "YLImageProcess.h"

@interface YLPSDImageData()

@property (nonatomic, strong, readwrite) YLPSDImageDataInfo *imageData;

@end

@implementation YLPSDImageData

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index channel:(unsigned int)channel colorMode:(NSInteger)colorMode width:(unsigned int)width height:(unsigned int)height {
    self.startIndex = index;
    
    _imageData = [YLPSDImageDataInfo new];
    _imageData.startIndex = index;
    
    unsigned char compress[2] = {0};
    [fileData getBytes:&compress range:NSMakeRange(index, sizeof(compress))];
    unsigned short int compression = [YLDataProcess bytesToInt:compress length:sizeof(compress)];
    NSLog(@"compression method is %d", compression);
    
    index += sizeof(compress);
        
    NSMutableArray *imageData = [NSMutableArray array];
            
    NSInteger ciIndex = index;

    unsigned int numPixels = width * height;
    
    switch (compression) {
        case 0:
        {
            NSInteger count = numPixels * channel;
            if (count > 2) {
//                unsigned int lines[count];
                unsigned int *lines = (unsigned int *)malloc(count * sizeof(unsigned int));
                for (NSInteger k=0; k<count; k++) {
                    unsigned char value[1] = {0};
                    [fileData getBytes:&value range:NSMakeRange(ciIndex, sizeof(value))];
                    unsigned int byteCount = [YLDataProcess bytesToInt:value length:sizeof(value)];
                    lines[k] = byteCount;
                    ciIndex += sizeof(value);
                }
                
                for (NSInteger i = 0; i < 3; i++) {
                    YLPSDChannelInfo *channelInfo = [YLPSDChannelInfo new];
                    channelInfo.channelId = i;
                    channelInfo.length = numPixels;
                    unsigned int *heightLines = (unsigned int *)malloc(numPixels * sizeof(unsigned int));
                    
                    for (NSInteger j=0; j<numPixels; j++) {
                        heightLines[j] = lines[i*numPixels+j];
                    }
                    imageData = [YLPSDChannelImage imageDataForData:heightLines channelInfo:channelInfo colorMode:colorMode size:CGSizeMake(width, height) imageData:imageData];
                    
//                    UIImage *image = drawImageWithRGB(imageData, width, height, nil);
                    
                    free(heightLines);
                    
                }
                free(lines);
            }
        }
            break;
        case 1:{
            
            NSInteger count = height * channel;

            if (count > 2) {
//                unsigned short int linesLength[count];
                unsigned short int *linesLength = (unsigned short int *)malloc(count * sizeof(unsigned short int));
                NSInteger total = 0;

                for (NSInteger k=0; k<count; k++) {
                    unsigned char idByteCount[2] = {0};
                    [fileData getBytes:&idByteCount range:NSMakeRange(ciIndex, sizeof(idByteCount))];
                    unsigned short int byteCount = [YLDataProcess bytesToInt:idByteCount length:sizeof(idByteCount)];
                    linesLength[k] = byteCount;
                    ciIndex += sizeof(idByteCount);
                    total += byteCount;
                }
                
                count = numPixels * channel;
                
                NSInteger channel_pos = 0;
//                unsigned int lines[count];
                unsigned int *lines = (unsigned int *)malloc(count * sizeof(unsigned int));
                
                for (NSInteger i=0; i<channel; i++) {
                    for (NSInteger k=0; k<height; k++) {
                        NSInteger currentIndex = ciIndex;
                        unsigned short int byteCount = linesLength[i*height+k];
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
                                    if (channel_pos > count) {
                                        break;
                                    }
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
                                    if (channel_pos > count) {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                
                free(linesLength);
                
                if (channel_pos != count) {
                    NSLog(@"image data count is not match:%ld,%ld",channel_pos,count);
                }
                
                for (NSInteger i = 0; i < 3; i++) {
                    YLPSDChannelInfo *channelInfo = [YLPSDChannelInfo new];
                    channelInfo.channelId = i;
                    channelInfo.length = numPixels;
                    unsigned int *heightLines = (unsigned int *)malloc(numPixels * sizeof(unsigned int));
                    
                    for (NSInteger j=0; j<numPixels; j++) {
                        heightLines[j] = lines[i*numPixels+j];
                    }
                    imageData = [YLPSDChannelImage imageDataForData:heightLines channelInfo:channelInfo colorMode:colorMode size:CGSizeMake(width, height) imageData:imageData];
                    
//                    UIImage *image = drawImageWithRGB(imageData, width, height, nil);
                    
                    free(heightLines);
                    
                }
                free(lines);
            }
        }
            break;
        default:
            break;
    }
    
    index = ciIndex;

    UIImage *image = drawImageWithRGB(imageData, width, height, nil);
    _imageData.image = image;
    
    _imageData.endIndex = index;
    self.endIndex = index;
    return YES;
}

@end
