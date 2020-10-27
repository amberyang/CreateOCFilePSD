//
//  YLPSDImageResource.m
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDImageResource.h"
#import "YLDataProcess.h"
#import "YLPSDImageResourceBlock.h"

@interface YLPSDImageResource()

@property (nonatomic, strong, readwrite) YLPSDImageResourceInfo *imageResourceInfo;

@end

@implementation YLPSDImageResource

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {
    
    self.startIndex = index;
    
    _imageResourceInfo = [YLPSDImageResourceInfo new];
    _imageResourceInfo.startIndex = index;
    
    unsigned char imgLength[4] = {0};
    [fileData getBytes:&imgLength range:NSMakeRange(index, sizeof(imgLength))];
    unsigned int imageLength = [YLDataProcess bytesToInt:imgLength length:sizeof(imgLength)];
    NSLog(@"image resource length is %d", imageLength);
    _imageResourceInfo.length = imageLength;
    
    index += sizeof(imgLength);

    NSInteger endIndex = index + imageLength;
    
    NSMutableArray *array = [NSMutableArray array];
        
    while (index < endIndex) {
        
        YLPSDImageResourceBlock *block = [YLPSDImageResourceBlock new];
        [block parse:fileData index:index];
        
        index = block.endIndex;
        [array addObject:block.blockInfo];
    }
    _imageResourceInfo.blocks = array;
    
    if (endIndex != index) {
        index = endIndex;
        NSLog(@"image length and block data is not match: %ld, %ld",endIndex,index);
    }
    
    _imageResourceInfo.endIndex = index;
    self.endIndex = index;
    return YES;
}


@end
