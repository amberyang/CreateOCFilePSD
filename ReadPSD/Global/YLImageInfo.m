//
//  YLImageInfo.m
//  ReadPSD
//
//  Created by amber on 2019/11/28.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLImageInfo.h"

@implementation YLImageInfo

- (NSMutableArray *)layers {
    if (!_layers) {
        _layers = [NSMutableArray array];
    }
    return _layers;
}

@end
