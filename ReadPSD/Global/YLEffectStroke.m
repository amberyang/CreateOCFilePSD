//
//  YLEffectStroke.m
//  ReadPSD
//
//  Created by amber on 2019/12/24.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLEffectStroke.h"
#import "YLEffect.h"

@implementation YLEffectStroke

+ (YLEffectStroke *)createStokeWithArray:(NSArray *)array {
    YLEffectStroke *frfx = [YLEffectStroke new];
    for (NSDictionary *dic in array) {
        if ([dic objectForKey:@"enab"]) {
            frfx.enab = [[[dic objectForKey:@"enab"] objectForKey:@"bool"] boolValue];
        }
        if ([dic objectForKey:@"styl"]) {
            frfx.styl = [[dic objectForKey:@"styl"] objectForKey:@"enum"];
        }
        if ([dic objectForKey:@"opct"]) {
            frfx.opct = [[[dic objectForKey:@"opct"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"sz"]) {
            frfx.sz = [[[dic objectForKey:@"sz"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"type"]) {
            frfx.type = [[dic objectForKey:@"type"] objectForKey:@"enum"];
        }
        if ([dic objectForKey:@"overprint"]) {
            frfx.overprint = [[[dic objectForKey:@"overprint"] objectForKey:@"bool"] boolValue];
        }
        if ([dic objectForKey:@"clr"]) {
            id value = [YLEffect getDataWithArray:array key:@[@"clr",@"objc",@"rgbc"]];
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *rgbc = (NSArray *)value;
                YLRGBA *rgba = [YLRGBA new];
                for (NSDictionary *objc in rgbc) {
                    if ([objc objectForKey:@"rd"]) {
                        rgba.red = [[[objc objectForKey:@"rd"] objectForKey:@"doub"] doubleValue];
                    }
                    if ([objc objectForKey:@"grn"]) {
                        rgba.green = [[[objc objectForKey:@"grn"] objectForKey:@"doub"] doubleValue];
                    }
                    if ([objc objectForKey:@"bl"]) {
                        rgba.blue = [[[objc objectForKey:@"bl"] objectForKey:@"doub"] doubleValue];
                    }
                }
                frfx.rgba = rgba;
            }
        }
    }
    frfx.rgba.alpha = frfx.opct * 255.0 / 100.0;
    if (frfx.enab) {
        return frfx;
    }
    return nil;
}

@end
