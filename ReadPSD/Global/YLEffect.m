//
//  YLEffect.m
//  ReadPSD
//
//  Created by amber on 2019/12/20.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLEffect.h"

@implementation YLEffect

+ (id)getDataWithArray:(NSArray *)array key:(NSArray *)keys {
    id value;
    for (NSDictionary *dic in array) {
        BOOL stop;
        value = [[self class] parseValue:dic stop:&stop key:keys index:0];
        if (stop) {
            break;
        }
    }
    return value;
}

+ (id)parseValue:(id)data stop:(BOOL *)stop key:(NSArray *)keys index:(NSInteger)index {
    id value;
    if (index < keys.count) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            if ([(NSDictionary *)data objectForKey:[keys objectAtIndex:index]]) {
                if (index == keys.count - 1) {
                    *stop = YES;
                    return [(NSDictionary *)data objectForKey:[keys objectAtIndex:index]];
                } else {
                    value = [[self class] parseValue:[(NSDictionary *)data objectForKey:[keys objectAtIndex:index]] stop:stop key:keys index:(index+1)];
                }
            }
        } else if ([data isKindOfClass:[NSArray class]]) {
            for (id objc in (NSArray *)data) {
                value = [[self class] parseValue:objc stop:stop key:keys index:index];
                if (*stop) {
                    break;
                }
            }
        }
    }
    return value;
}

@end
