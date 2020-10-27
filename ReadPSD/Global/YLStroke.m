//
//  YLStroke.m
//  ReadPSD
//
//  Created by amber on 2020/6/9.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLStroke.h"
#import "YLEffect.h"

@implementation YLStroke

+ (YLStroke *)createStokeWithArray:(NSArray *)array {
    YLStroke *strokestyle = [YLStroke new];
    for (NSDictionary *dic in array) {
        if ([dic objectForKey:@"strokeenabled"]) {
            strokestyle.strokeenabled = [[[dic objectForKey:@"strokeenabled"] objectForKey:@"bool"] boolValue];
        }
        if ([dic objectForKey:@"fillenabled"]) {
            strokestyle.fillenabled = [[[dic objectForKey:@"fillenabled"] objectForKey:@"bool"] boolValue];
        }
        if ([dic objectForKey:@"strokestylelinejointype"]) {
            strokestyle.strokestylelinejointype = [[dic objectForKey:@"strokestylelinejointype"] objectForKey:@"enum"];
        }
        if ([dic objectForKey:@"strokestyleopacity"]) {
            strokestyle.strokestyleopacity = [[[dic objectForKey:@"strokestyleopacity"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"strokestylelinewidth"]) {
            strokestyle.strokestylelinewidth = [[[dic objectForKey:@"strokestylelinewidth"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"strokestyleblendmode"]) {
            strokestyle.strokestyleblendmode = [[dic objectForKey:@"strokestyleblendmode"] objectForKey:@"enum"];
        }
        if ([dic objectForKey:@"strokestylecontent"]) {
            id value = [YLEffect getDataWithArray:array key:@[@"strokestylecontent",@"objc",@"solidcolorlayer",@"clr",@"objc",@"rgbc"]];
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
                strokestyle.rgba = rgba;
            }
        }
    }
    strokestyle.rgba.alpha = strokestyle.strokestyleopacity * 255.0 / 100.0;
    if (strokestyle.strokeenabled) {
        return strokestyle;
    }
    return nil;
}

@end
