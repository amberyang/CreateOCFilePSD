//
//  YLGradient.m
//  ReadPSD
//
//  Created by amber on 2019/12/19.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLGradient.h"

@implementation YLGradient

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        self.enab = YES;
//    }
//    return self;
//}

+ (YLGradient *)createGradientWithArray:(NSArray *)array {
    YLGradient *gradient = [YLGradient new];
    gradient.enab = YES;
    for (NSDictionary *dic in array) {
        if ([dic objectForKey:@"angl"]) {
            gradient.angl = [[[dic objectForKey:@"angl"] objectForKey:@"untf"] floatValue];
        }
        if ([dic objectForKey:@"enab"]) {
            gradient.enab = [[[dic objectForKey:@"enab"] objectForKey:@"bool"] boolValue];
        }
        if ([dic objectForKey:@"type"]) {
            gradient.type = [[dic objectForKey:@"type"] objectForKey:@"enum"];
        }
        if ([dic objectForKey:@"opct"]) {
            gradient.opct = [[[dic objectForKey:@"opct"] objectForKey:@"untf"] doubleValue];
        }
        if ([dic objectForKey:@"rvrs"]) {
            gradient.rvrs = [[[dic objectForKey:@"rvrs"] objectForKey:@"bool"] boolValue];
        }
        if ([dic objectForKey:@"grad"]) {
            NSArray *gradObjc = [[[dic objectForKey:@"grad"] objectForKey:@"objc"] objectForKey:@"grdn"];
            for (NSDictionary *gradobj in gradObjc) {
                NSArray *clrs = [[gradobj objectForKey:@"clrs"] objectForKey:@"vlls"];
                NSMutableArray *grads = [NSMutableArray array];
                for (NSDictionary *list in clrs) {
                    NSArray *listObj = [[list objectForKey:@"objc"] objectForKey:@"clrt"];
                    YLRGBAGradient *rgba = [YLRGBAGradient new];
                    for (NSDictionary *clr in listObj) {
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
                        if ([clr objectForKey:@"lctn"]) {
                            float pos1 = [[[clr objectForKey:@"lctn"] objectForKey:@"long"] longValue]/4096.0;
                            rgba.position = pos1;
                        }
                        if ([clr objectForKey:@"mdpn"]) {
                            float pos2 = [[[clr objectForKey:@"mdpn"] objectForKey:@"long"] longValue]/100.0;
                        }
        //                if (pos1 > pos2) {
        //                    rgba.begin = pos2;
        //                    rgba.end = pos1;
        //                } else {
        //                    rgba.begin = pos1;
        //                    rgba.end = pos2;
        //                }
                    }
                    
                    [grads addObject:rgba];
                }
                
                if (grads.count > 0) {
                    gradient.gradients = grads;
                    break;
                }
            }
            
            for (NSDictionary *gradobj in gradObjc) {
                NSArray *trns = [[gradobj objectForKey:@"trns"] objectForKey:@"vlls"];
                NSInteger index = 0;
                for (NSDictionary *list in trns) {
                    NSArray *listObj = [[list objectForKey:@"objc"] objectForKey:@"trns"];
                    for (NSDictionary *opct in listObj) {
                        if ([opct objectForKey:@"opct"]) {
                            YLRGBAGradient *rgba = [gradient.gradients objectAtIndex:index];
                            rgba.alpha = [[[opct objectForKey:@"opct"] objectForKey:@"untf"] doubleValue] * 255.0/100.0;
                            index++;
                        }
                    }
                }
            }
        }
    }
    if (gradient.enab) {
        return gradient;
    }
    return nil;
}

@end
