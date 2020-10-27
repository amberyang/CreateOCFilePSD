//
//  YLBGRGBA.m
//  ReadPSD
//
//  Created by amber on 2019/12/18.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLBGRGBA.h"

@implementation YLBGRGBA

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sameColor = YES;
        self.sameRGB = YES;
        self.alpha = 0;
    }
    return self;
}

- (YLCircularRadius *)circular {
    if (!_circular) {
        _circular = [[YLCircularRadius alloc] init];
    }
    return _circular;
}

- (YLEffect *)effect {
    if (!_effect) {
        _effect = [[YLEffect alloc] init];
    }
    return _effect;
}

@end
