//
//  YLRGBA.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLRGBA.h"

@implementation YLRGBA

- (instancetype)init {
    self = [super init];
    if (self) {
        _red = _green = _blue = 0;
        _alpha = 255;
        _mask = 255;
    }
    return self;
}

+ (YLRGBA *)createRGBAColor:(NSArray *)array {
    YLRGBA *rgba = [YLRGBA new];
    if (array.count == 4) {
        NSString *a = [array objectAtIndex:0];
        rgba.alpha = [[self class] getValueFromPercent:a];
        NSString *r = [array objectAtIndex:1];
        rgba.red = [[self class] getValueFromPercent:r];
        NSString *g = [array objectAtIndex:2];
        rgba.green = [[self class] getValueFromPercent:g];
        NSString *b = [array objectAtIndex:3];
        rgba.blue = [[self class] getValueFromPercent:b];
    }
    return rgba;
}

+ (YLRGBA *)createRGBAWithArray:(NSArray *)array {
    YLRGBA *rgba = [YLRGBA new];
    for (NSDictionary *dic in array) {
        if ([dic objectForKey:@"clr"]) {
            NSArray *rgbc = [[[dic objectForKey:@"clr"] objectForKey:@"objc"] objectForKey:@"rgbc"];
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
        }
        if ([dic objectForKey:@"opct"]) {
            rgba.alpha = [[[dic objectForKey:@"opct"] objectForKey:@"untf"] floatValue] * 255.0 / 100.0;
        }
        if ([dic objectForKey:@"enab"]) {
            rgba.enab = [[[dic objectForKey:@"enab"] objectForKey:@"bool"] boolValue];
        }
    }
    return rgba;
}

+ (unsigned int)getValueFromPercent:(NSString *)value {
    if ([value hasPrefix:@"."]) {
        value = [@"0" stringByAppendingString:value];
    }
    return (unsigned int)([value floatValue] * 255);
}

+ (UIColor *)colorWithRGBA:(YLRGBA *)rgba {
    UIColor *color = [UIColor colorWithRed:rgba.red/255.0 green:rgba.green/255.0 blue:rgba.blue/255.0 alpha:rgba.alpha/255.0];
    return color;
}

+ (UIColor *)colorWithRGBA:(YLRGBA *)rgba overlay:(YLRGBA *)overlay {
    if (!overlay) {
        return [[self class] colorWithRGBA:rgba];
    }
    if (!rgba) {
        return [[self class] colorWithRGBA:overlay];
    }
    NSInteger red = [self colorValue:rgba.red alpha:rgba.alpha overlay:overlay.red alpha:overlay.alpha];
    NSInteger green = [self colorValue:rgba.green alpha:rgba.alpha overlay:overlay.green alpha:overlay.alpha];
    NSInteger blue = [self colorValue:rgba.blue alpha:rgba.alpha overlay:overlay.blue alpha:overlay.alpha];
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return color;
}

+ (NSInteger)colorValue:(NSInteger)value1 alpha:(NSInteger)alpha1 overlay:(NSInteger)value2 alpha:(NSInteger)alpha2 {
    value1 = value1 * (alpha1 / 255.0) * (1 - (alpha2 / 255.0));
    value2 = value2 * (alpha2 / 255.0);
    return MIN((value1 + value2), 255.0);
}

- (BOOL)isEqual:(YLRGBA *)object {
    BOOL isEqual = [super isEqual:object];
    if (!isEqual) {
        if (self.red == object.red && self.green == object.green
            && self.blue == object.blue && self.alpha == object.alpha) {
            return YES;
        }
    }
    return isEqual;
}

- (BOOL)isEqualWithoutAlpha:(YLRGBA *)object {
    BOOL isEqual = [super isEqual:object];
    if (!isEqual) {
        if (self.red == object.red && self.green == object.green
            && self.blue == object.blue) {
            return YES;
        }
    }
    return isEqual;
}

+ (YLRGBA *)rgbaColorFromUIColor:(UIColor *)color {
    size_t numComponents = CGColorGetNumberOfComponents(color.CGColor);
    YLRGBA *rbga = [YLRGBA new];
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rbga.red = components[0] * 255.0;
        rbga.green = components[1] * 255.0;
        rbga.blue = components[2] * 255.0;
        rbga.alpha = components[3] * 255.0;
    }
    return rbga;
}

- (NSString *)description {
    NSString *desc = [NSString stringWithFormat:@"red:%d,green:%d,blue:%d,alpha:%d",self.red,self.green,self.blue,self.alpha];
    return desc;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    YLRGBA *copyObj = [YLRGBA new];
    copyObj.red = self.red;
    copyObj.green = self.green;
    copyObj.blue = self.blue;
    copyObj.alpha = self.alpha;
    return copyObj;
}


@end
