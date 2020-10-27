//
//  YLPSDLayerInfo.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDLayerInfo.h"
#import "YLDataProcess.h"
#import "YLPSDLayerRecord.h"
#import "YLPSDChannelImage.h"
#import "YLImageProcess.h"

@interface YLPSDLayerInfo()

@property (nonatomic, strong, readwrite) YLPSDLayerInfoInfo *layerInfo;

@end

@implementation YLPSDLayerInfo

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index channel:(unsigned int)channel colorMode:(NSInteger)colorMode {

    self.startIndex = index;
    
    _layerInfo = [YLPSDLayerInfoInfo new];
    _layerInfo.startIndex = index;
    
#pragma mark ------ Layer info
    
    //Length of the layers info section, rounded up to a multiple of 2.
    unsigned char lyiLength[4] = {0};
    [fileData getBytes:&lyiLength range:NSMakeRange(index, sizeof(lyiLength))];
    unsigned int layerInfoLength = [YLDataProcess bytesToInt:lyiLength length:sizeof(lyiLength)];
    layerInfoLength = ((layerInfoLength + 1) & ~0x01);
    NSLog(@"layer info length is %d", layerInfoLength);
    _layerInfo.length = layerInfoLength;

    index += sizeof(lyiLength);
    NSInteger endIndex = index + layerInfoLength;

    if (layerInfoLength > 0) {
        
#pragma mark ------ Layer structure
        
        //Number of layers. If <0, then number of layers is absolute value, and the first alpha channel contains the transparency data for the merged result.
        unsigned char lycLength[2] = {0};
        [fileData getBytes:&lycLength range:NSMakeRange(index, sizeof(lycLength))];
        short int layerCount = [YLDataProcess bytesToInt:lycLength length:sizeof(lycLength)];
        if (layerCount < 0) {
            layerCount = abs(layerCount);
        }
        
        NSLog(@"layer count is %d", layerCount);
        _layerInfo.layerCount = layerCount;
        
        index += sizeof(lycLength);
        
        if ((layerCount * (18 + 6*channel)) > layerInfoLength) {
            return NO;
        }
        
#pragma mark ------ Layer records
                
        NSMutableArray *array = [NSMutableArray array];
                
        for (NSInteger i=0; i<layerCount; i++) {
            
            YLPSDLayerRecord *record = [YLPSDLayerRecord new];
            [record parse:fileData index:index];
            [array addObject:record.record];
            index = record.endIndex;
        }
        
//        for (NSInteger i=0; i<layerCount; i++) {
//            YLPSDLayerRecordInfo *info = [array objectAtIndex:i];
//            NSLog(@"%@",[NSValue valueWithUIEdgeInsets:info.layerInsets]);
//        }
//        
//        NSLog(@"~~~~~~~~~~~~~~`");
        NSArray *reversedArray = [[array reverseObjectEnumerator] allObjects];
        _layerInfo.records = [self layerObjectStruct:reversedArray endIndex:nil];
        
//        for (NSInteger i=0; i<layerCount; i++) {
//            YLPSDLayerRecordInfo *info = [array objectAtIndex:i];
//            NSLog(@"%@",[NSValue valueWithUIEdgeInsets:info.layerInsets]);
//        }
//        
//        NSLog(@"~~~~~~~~~~~~~~`");
        
#pragma mark --- channel image data
        
        for (NSInteger i=0; i<layerCount; i++) {
            
            YLPSDLayerRecordInfo *record = [array objectAtIndex:i];
            
            NSInteger layerWidth = record.layerInsets.right - record.layerInsets.left;
            NSInteger layerHeight = record.layerInsets.bottom - record.layerInsets.top;
            
            NSMutableArray *channelData = [NSMutableArray array];
            
            for (NSInteger j=0; j<record.channelCount; j++) {
                
                YLPSDChannelInfo *channelInfo = [record.channelInfos objectAtIndex:j];
                
                unsigned char compress[2] = {0};
                [fileData getBytes:&compress range:NSMakeRange(index, sizeof(compress))];
                unsigned short int compression = [YLDataProcess bytesToInt:compress length:sizeof(compress)];
                NSLog(@"compression method is %d", compression);
                record.compression = compression;
                
                if (channelInfo.channelId < -1) {
                    record.hasMask = YES;
                    layerWidth = record.layerMask.layerMaskInsets.right - record.layerMask.layerMaskInsets.left;
                    layerHeight = record.layerMask.layerMaskInsets.bottom - record.layerMask.layerMaskInsets.top;
                }
                                                
                NSInteger ciIndex;
                                   
                channelData = [YLPSDChannelImage channelImageDataForCompression:compression channelInfo:channelInfo fileData:fileData colorMode:colorMode currentIndex:index offset:sizeof(compress) size:CGSizeMake(layerWidth, layerHeight) imageData:channelData endIndex:&ciIndex];
                
                index += channelInfo.length;

                if (index != ciIndex) {
                   NSLog(@"layer image length is not match: %ld, %ld",index, ciIndex);
                }
            }

//            if (channelData.count > 0) {
            layerWidth = record.layerInsets.right - record.layerInsets.left;
            layerHeight = record.layerInsets.bottom - record.layerInsets.top;
            YLBGRGBA *bgRGBA;
            UIImage *image = drawImageWithRecord(record, channelData, layerWidth, layerHeight, &bgRGBA);
            [record updateChildEffect];
            record.image = image;
            record.bgColor = bgRGBA;
//            }
        }
    }

    if (index != endIndex) {
        NSLog(@"layer info length is not match: %ld, %ld",index, endIndex);
        index = endIndex;
    }
    self.endIndex = index;
    return YES;
}

#pragma mark --- data trans
- (NSMutableArray *)layerObjectStruct:(NSArray *)array endIndex:(NSInteger *)endIndex {
    NSMutableArray *group = [NSMutableArray array];
    NSInteger count = array.count;
    BOOL isFinish = NO;
    NSInteger groupEndIndex = 0;
    for (NSInteger i=0; i<count; i++) {
        YLPSDLayerRecordInfo *record = [array objectAtIndex:i];
        switch (record.layerType) {
            case 1:
            {
                NSMutableArray *subGroup = [self layerObjectStruct:[array subarrayWithRange:NSMakeRange(i+1, count-i-1)] endIndex:&groupEndIndex];
                record.records = subGroup;
                [self groupInsetsTransform:record];
                [group addObject:record];
                i += groupEndIndex;
            }
               break;
            case 2:
            {
                NSMutableArray *subGroup = [self layerObjectStruct:[array subarrayWithRange:NSMakeRange(i+1, count-i-1)] endIndex:&groupEndIndex];
                record.records = subGroup;
                [self groupInsetsTransform:record];
                [group addObject:record];
                i += groupEndIndex;
            }
               break;
            case 3:
            {
                isFinish = YES;
                *endIndex = (i+1);
            }
                break;
            default:
            {
                [group addObject:record];
            }
                break;
        }
        if (isFinish) {
            break;
        }
    }
    return group;
}

- (void)groupInsetsTransform:(YLPSDLayerRecordInfo *)record {
    CGFloat top = CGFLOAT_MAX, left = CGFLOAT_MAX, bottom = -CGFLOAT_MAX, right = -CGFLOAT_MAX;
    for (YLPSDLayerRecordInfo *layerRecord in record.records) {
        top = MIN(layerRecord.layerInsets.top, top);
        left = MIN(layerRecord.layerInsets.left, left);
        bottom = MAX(layerRecord.layerInsets.bottom, bottom);
        right = MAX(layerRecord.layerInsets.right, right);
    }
    record.layerInsets = UIEdgeInsetsMake(MAX(top, 0), MAX(left, 0), MAX(bottom, 0), MAX(right, 0));
    for (YLPSDLayerRecordInfo *layerRecord in record.records) {
        bottom = layerRecord.layerInsets.bottom - record.layerInsets.top;
        right = layerRecord.layerInsets.right - record.layerInsets.left;
        top = layerRecord.layerInsets.top - record.layerInsets.top;
        left = layerRecord.layerInsets.left - record.layerInsets.left;
        layerRecord.layerInsets = UIEdgeInsetsMake(top, left, bottom, right);
    }
}

@end
