//
//  YLPSDGlobalLayerMask.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDGlobalLayerMask.h"
#import "YLDataProcess.h"

@interface YLPSDGlobalLayerMask()

@property (nonatomic, strong, readwrite) YLPSDGlobalLayerMaskInfo *globalLayerMask;

@end

@implementation YLPSDGlobalLayerMask

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {

    self.startIndex = index;
    
#pragma mark -----  Global layer mask info
    
    //Length of global layer mask info section.
    unsigned char glmLength[4] = {0};
    [fileData getBytes:&glmLength range:NSMakeRange(index, sizeof(glmLength))];
    unsigned int globalLayerLength = [YLDataProcess bytesToInt:glmLength length:sizeof(glmLength)];
    NSLog(@"global layer mask length is %d", globalLayerLength);
    
    index += sizeof(glmLength);
    NSInteger endIndex = index + globalLayerLength;
    
    if (globalLayerLength > 0) {
        //Overlay color space (undocumented).
        unsigned char overlay[2] = {0};
        [fileData getBytes:&overlay range:NSMakeRange(index, sizeof(overlay))];
        unsigned short int overlayColorSpace = [YLDataProcess bytesToInt:overlay length:sizeof(overlay)];
        NSLog(@"overlay color space is %d", overlayColorSpace);
        
        index += sizeof(overlay);
        
        //4 * 2 byte color components
        for (NSInteger m=0; m<4; m++) {
            unsigned char colorComp[2] = {0};
            [fileData getBytes:&colorComp range:NSMakeRange(index, sizeof(colorComp))];
            unsigned short int colorComponents = [YLDataProcess bytesToInt:colorComp length:sizeof(colorComp)] >> 8;
            NSLog(@"color component is %d", colorComponents);
            
            index += sizeof(colorComp);
        }
        
        //0 = transparent, 100 = opaque.
        unsigned char glmopacity[2] = {0};
        [fileData getBytes:&glmopacity range:NSMakeRange(index, sizeof(glmopacity))];
        unsigned short int glmOpacity = [YLDataProcess bytesToInt:glmopacity length:sizeof(glmopacity)];
        NSLog(@"global layer mask opacity is %d", glmOpacity);
        
        index += sizeof(glmopacity);
        
        //0=Color selected—i.e. inverted; 1=Color protected;128=use value stored per layer. This value is preferred. The others are for back- ward compatibility with beta versions.
        unsigned char kind[1] = {0};
        [fileData getBytes:&kind range:NSMakeRange(index, sizeof(kind))];
        unsigned short int glmKind = [YLDataProcess bytesToInt:kind length:sizeof(kind)];
        NSLog(@"global layer mask color kind is %d", glmKind);
        
        index += sizeof(kind);
        
        //(zero)
        unsigned char filler[1] = {0};
        [fileData getBytes:&filler range:NSMakeRange(index, sizeof(filler))];
        unsigned int glmFiller = [YLDataProcess bytesToInt:filler length:sizeof(filler)];
        NSLog(@"filler is %d", glmFiller);
        
        index += sizeof(filler);
    }
    
    if (index != endIndex) {
        NSLog(@"global layer mask length is not match: %ld,%ld",index,endIndex);
        index = endIndex;
    }
    
    self.endIndex = index;
    return YES;
}

@end
