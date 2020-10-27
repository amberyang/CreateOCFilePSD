//
//  YLPSDColorModeData.m
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDColorModeData.h"
#import "YLDataProcess.h"

@interface YLPSDColorModeData()

@property (nonatomic, strong, readwrite) YLPSDColorModeInfo *colorModeInfo;

@end

@implementation YLPSDColorModeData

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index colorMode:(unsigned int)colorMode {
    //Only indexed color and duotone have color mode data. For all other modes, this section is just 4 bytes: the length field, which is set to zero.
    //For indexed color images, the length will be equal to 768, and the color data will contain the color table for the image, in non–interleaved order
    //For duotone images, the color data will contain the duotone specification, the format of which is not documented. Other applications that read Photoshop files can treat a duotone image as a grayscale image, and just preserve the contents of the duotone information when reading and writing the file.
    //The length of the following color data.
    
    self.startIndex = index;
    
    unsigned char cdlength[4] = {0};
    [fileData getBytes:&cdlength range:NSMakeRange(index, sizeof(cdlength))];
    unsigned int colorDataLength = [YLDataProcess bytesToInt:cdlength length:sizeof(cdlength)];
    NSLog(@"color data length is %d", colorDataLength);
    
    if (colorDataLength == 0 && (colorMode == 2 || colorMode == 8)) {
        return NO;
    }
    
    _colorModeInfo = [YLPSDColorModeInfo new];
    _colorModeInfo.length = colorDataLength;
    _colorModeInfo.startIndex = index;
    
    //Indexed color images: length is 768; color data contains the color table for the image, in non-interleaved order
    if (colorDataLength == 768) {
        
    }
   
    if (colorDataLength != 0 && colorMode == 8) {
        
    }
    
    index += sizeof(cdlength) + colorDataLength;
    
    _colorModeInfo.endIndex = index;
    self.endIndex = index;
    return YES;
}

@end
