//
//  YLLayerInfo.m
//  ReadPSD
//
//  Created by amber on 2019/10/9.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLLayerInfo.h"

@implementation YLLayerInfo

- (NSMutableArray *)layers {
    if (!_layers) {
        _layers = [NSMutableArray array];
    }
    return _layers;
}

@end
