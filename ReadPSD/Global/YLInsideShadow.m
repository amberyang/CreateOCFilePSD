//
//  YLInsideShadow.m
//  ReadPSD
//
//  Created by amber on 2019/12/23.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLInsideShadow.h"
#import "YLEffect.h"

@implementation YLInsideShadow

+ (YLInsideShadow *)createInsideShadowWithArray:(NSArray *)array {
    YLInsideShadow *irsh = [YLInsideShadow new];
    for (NSDictionary *dic in array) {
        if ([dic objectForKey:@"enab"]) {
            irsh.enab = [[[dic objectForKey:@"enab"] objectForKey:@"bool"] boolValue];
        }
        if ([dic objectForKey:@"opct"]) {
            irsh.opct = [[[dic objectForKey:@"opct"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"lagl"]) {
            irsh.lagl = [[[dic objectForKey:@"lagl"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"dstn"]) {
            irsh.dstn = [[[dic objectForKey:@"dstn"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"blur"]) {
            irsh.blur = [[[dic objectForKey:@"blur"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"clr"]) {
            id value = [YLEffect getDataWithArray:array key:@[@"clr",@"objc"]];
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *clrs = (NSArray *)value;
                YLRGBA *rgba = [YLRGBA new];
                for (NSDictionary *clr in clrs) {
                    NSArray *colorObj = [[[clr objectForKey:@"clr"] objectForKey:@"objc"] objectForKey:@"rgbc"];
                    for (NSDictionary *objc in colorObj) {
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
                }
                irsh.rgba = rgba;
            }
        }
    }
    irsh.rgba.alpha = irsh.opct * 255.0 / 100.0;
    if (irsh.enab) {
        return irsh;
    }
    return nil;
}

@end
