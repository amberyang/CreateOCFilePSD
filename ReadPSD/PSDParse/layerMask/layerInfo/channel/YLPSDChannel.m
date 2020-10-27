//
//  YLPSDChannel.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDChannel.h"
#import "YLDataProcess.h"

@interface YLPSDChannel()

@property (nonatomic, strong, readwrite) YLPSDChannelInfo *channelInfo;

@end

@implementation YLPSDChannel

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {
    self.startIndex = index;
    _channelInfo = [YLPSDChannelInfo new];
    _channelInfo.startIndex = index;
    
    //Channel information. This contains a six byte record for each channel
    //ix bytes per channel, consisting of:
    //2 bytes for Channel ID: 0 = red, 1 = green, etc.;
    //-1 = transparency mask; -2 = user supplied layer mask, -3 real user supplied layer mask
    unsigned char channelid[2] = {0};
    [fileData getBytes:&channelid range:NSMakeRange(index, sizeof(channelid))];
    short int channelID = [YLDataProcess bytesToInt:channelid length:sizeof(channelid)];
    NSLog(@"channel id is %d", channelID);
    _channelInfo.channelId = channelID;
    
    index += sizeof(channelid);
    
    unsigned char channelLeg[4] = {0};
    [fileData getBytes:&channelLeg range:NSMakeRange(index, sizeof(channelLeg))];
    unsigned int channelLength = [YLDataProcess bytesToInt:channelLeg length:sizeof(channelLeg)];
    NSLog(@"channel length is %d", channelLength);
    _channelInfo.length = channelLength;
    
    index += sizeof(channelLeg);

    _channelInfo.endIndex = index;
    self.endIndex = index;
    return YES;
}

@end
