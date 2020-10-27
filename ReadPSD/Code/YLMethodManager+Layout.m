//
//  YLMethodManager+Layout.m
//  ReadPSD
//
//  Created by amber on 2020/6/19.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLMethodManager+Layout.h"
#import "YLPropertyT.h"

@implementation YLMethodManager (Layout)

+ (NSArray<NSString *> *)removeDuplicates:(NSString *)content array:(NSArray<NSString *> *)array {
    if (array.count == 0) {
        return [NSArray arrayWithObject:content];
    }
    NSMutableArray *layouts = [NSMutableArray arrayWithArray:array];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (NSInteger i=0; i<array.count; i++) {
        NSString *text = [array objectAtIndex:i];
        NSMutableString *modify = [[NSMutableString alloc] initWithString:text];
        for (NSString *line in lines) {
            if ([modify containsString:line]) {
                [modify replaceOccurrencesOfString:[NSString stringWithFormat:@"%@\n",line] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, modify.length)];
                if (modify.length > 0) {
                    [layouts replaceObjectAtIndex:i withObject:modify];
                } else {
                    [layouts removeObjectAtIndex:i];
                }
            } else {
                NSString *setFrame = @"setFrame:CGRectMake";
                NSRange range = [line rangeOfString:setFrame];
                if (range.location != NSNotFound) {
                    NSInteger valueStart = range.location + range.length;
                    NSString *prefix = [line substringToIndex:valueStart];
                    NSRange oldRange = [modify rangeOfString:prefix];
                    if (oldRange.location != NSNotFound) {
                        NSInteger index = oldRange.location + oldRange.length;
                        unichar letter = [modify characterAtIndex:index];
                        while (letter != '\n' && index < modify.length) {
                            index++;
                        }
                        [modify replaceCharactersInRange:NSMakeRange(oldRange.location, index-oldRange.location) withString:@""];
                        if (modify.length > 0) {
                            [layouts replaceObjectAtIndex:i withObject:modify];
                        } else {
                            [layouts removeObjectAtIndex:i];
                        }
                    }
                }
            }
        }
    }
    [layouts addObject:content];
    return layouts;
}

+ (NSArray<YLPropertyT *> *)getPointsRelation:(YLPSDLayerRecordInfo *)record frame:(CGRect)superFrame {
    NSString *regexString = @"\\s*(-?)([1-9]\\d*|0)\\.?\\d{0,2}\\s*";
    NSString *rectPrefix = @"CGRectMake";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"CGRectMake\\(%@,%@,%@,%@\\)",regexString,regexString,regexString,regexString] options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *sizePrefix = @"sizeThatFits:CGSizeMake";
    NSRegularExpression *sizeRegex = [[NSRegularExpression alloc] initWithPattern:@"sizeThatFits:CGSizeMake\\(\\s*[^,]*\\s*,\\s*CGFLOAT_MAX\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSMutableArray *framesArray = [NSMutableArray array];
    NSMutableDictionary *frameDic = [NSMutableDictionary dictionary];
    NSMutableArray<YLPropertyT *> *properties = [NSMutableArray array];
    for (NSInteger i=0; i<record.classObj.properties.count; i++) {
        YLPropertyT *property = [[record.classObj.properties objectAtIndex:i] copy];
        __block BOOL isFind = NO;
        __block NSString *sizeFit = nil;
        NSMutableArray *layoutsArray = [NSMutableArray array];
        for (NSInteger k=0; k<property.layout.count; k++) {
            __block BOOL isLayout = NO;
            NSString *layout = [property.layout objectAtIndex:k];
            [regex enumerateMatchesInString:layout options:NSMatchingReportProgress range:NSMakeRange(0, layout.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                if (result) {
                    NSLog(@"%@",[layout substringWithRange:result.range]);
                    NSString *value = [layout substringWithRange:NSMakeRange(result.range.location + rectPrefix.length + 1, result.range.length - rectPrefix.length - 2)];
                    value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSArray<NSString *> *values = [value componentsSeparatedByString:@","];
                    CGRect frame = CGRectMake([values objectAtIndex:0].floatValue, values[1].floatValue, values[2].floatValue, values[3].floatValue);
                    NSInteger index = properties.count;
//                    NSInteger index = 0;
//                    for (NSInteger j=0; j<framesArray.count; j++) {
//                        CGRect value = [[framesArray objectAtIndex:j] CGRectValue];
//                        if (CGRectGetMinY(frame) < CGRectGetMinY(value) && CGRectGetMaxY(frame) <= CGRectGetMinY(value)) {
//                            [framesArray insertObject:[NSValue valueWithCGRect:frame] atIndex:j];
//                            index = j;
//                            break;
//                        } else if (CGRectGetMinY(frame) < CGRectGetMinY(value) && CGRectGetMinX(frame) <= CGRectGetMinX(value)) {
//                            [framesArray insertObject:[NSValue valueWithCGRect:frame] atIndex:j];
//                            index = j;
//                            break;
//                        } else if (j == framesArray.count - 1) {
//                            [framesArray addObject:[NSValue valueWithCGRect:frame]];
//                            index = framesArray.count - 1;
//                            break;
//                        }
//                    }
//                    if (framesArray.count == 0) {
//                        [framesArray addObject:[NSValue valueWithCGRect:frame]];
//                    }
                    
                    NSMutableArray *strArray = [NSMutableArray arrayWithArray:values];
                    __block NSString *widthStr = [strArray objectAtIndex:2];
                    NSString *heightStr = [strArray objectAtIndex:3];
                    if (fabs((CGRectGetWidth(superFrame) - CGRectGetWidth(frame))/2 - CGRectGetMinX(frame)) <= 5) {
                        if (CGRectGetMinX(frame) == 0.0) {
                            widthStr = @"CGRectGetWidth(self.frame)";
                        } else {
                            widthStr = [NSString stringWithFormat:@"(CGRectGetWidth(self.frame) - (2 * %.1f))",ceil(CGRectGetMinX(frame))];
                        }
                    }
                    if (fabs((CGRectGetHeight(superFrame) - CGRectGetHeight(frame))/2 - CGRectGetMinY(frame)) <= 2) {
                        if (CGRectGetMinY(frame) == 0.0) {
                            heightStr = @"CGRectGetHeight(self.frame)";
                        } else {
                            heightStr = [NSString stringWithFormat:@"(CGRectGetHeight(self.frame) - (2 * %.1f))",ceil(CGRectGetMinY(frame))];
                        }
                    }
                    __block NSRange sizeRange = NSMakeRange(NSNotFound, 0);
                    __block NSMutableArray<NSString *> *sizeValues = nil;
                    [sizeRegex enumerateMatchesInString:layout options:NSMatchingReportProgress range:NSMakeRange(0, layout.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                        if (result) {
                            sizeRange = result.range;
                            NSString *sizeStr = [layout substringWithRange:NSMakeRange(result.range.location + sizePrefix.length + 1, result.range.length - sizePrefix.length - 2)];
                            NSString *sizeValue = [sizeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                            sizeValues = [NSMutableArray arrayWithArray:[sizeValue componentsSeparatedByString:@","]];
//                            if (![@"CGRectGetWidth(self.frame)" isEqualToString:sizeValues[0]]) {
                                [sizeValues replaceObjectAtIndex:0 withObject:widthStr];
//                            }
                            *stop = YES;
                        }
                    }];
                    
                    if (sizeRange.location == NSNotFound && sizeFit.length > 0) {
                        [sizeRegex enumerateMatchesInString:sizeFit options:NSMatchingReportProgress range:NSMakeRange(0, sizeFit.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                            if (result) {
                                sizeRange = result.range;
                                NSString *sizeStr = [sizeFit substringWithRange:NSMakeRange(result.range.location + sizePrefix.length + 1, result.range.length - sizePrefix.length - 2)];
                                NSString *sizeValue = [sizeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                                sizeValues = [NSMutableArray arrayWithArray:[sizeValue componentsSeparatedByString:@","]];
//                                widthStr = [widthStr stringByAppendingString:@""];
//                                if (![@"CGRectGetWidth(self.frame)" isEqualToString:sizeValues[0]]) {
                                    [sizeValues replaceObjectAtIndex:0 withObject:widthStr];
//                                }
                                *stop = YES;
                            }
                        }];
                    }
                    
                    if (property.calculateSize) {
                        [sizeRegex enumerateMatchesInString:property.calculateSize options:NSMatchingReportProgress range:NSMakeRange(0, property.calculateSize.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                            if (result) {
                                NSString *sizeStr = [property.calculateSize substringWithRange:NSMakeRange(result.range.location + sizePrefix.length + 1, result.range.length - sizePrefix.length - 2)];
                                NSString *sizeValue = [sizeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                                NSMutableArray<NSString *> *calValues = [NSMutableArray arrayWithArray:[sizeValue componentsSeparatedByString:@","]];
//                                if (![@"CGRectGetWidth(size.frame)" isEqualToString:calValues[0]]) {
                                    [calValues replaceObjectAtIndex:0 withObject:widthStr];
//                                }
                                property.calculateSize = [property.calculateSize stringByReplacingCharactersInRange:NSMakeRange(result.range.location + sizePrefix.length+1, result.range.length - sizePrefix.length-2) withString:[calValues componentsJoinedByString:@", "]];
                                *stop = YES;
                            }
                        }];
                    }
                    
                    if (sizeRange.location != NSNotFound) {
                        NSString *calSizeName = [NSString stringWithFormat:@"%@_size",property.name];
                        if (fabs((CGRectGetWidth(superFrame) - CGRectGetWidth(frame))/2 - CGRectGetMinX(frame)) <= 5) {
                            [strArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"((CGRectGetWidth(self.frame) - ceil(%@.width))/2)",calSizeName]];
                        }
                        widthStr = [NSString stringWithFormat:@"ceil(%@.width)",calSizeName];
                        
                        if (fabs((CGRectGetHeight(superFrame) - CGRectGetHeight(frame))/2 - CGRectGetMinY(frame)) <= 2) {
                            [strArray replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"((CGRectGetHeight(self.frame) - ceil(%@.height))/2)",calSizeName]];
                        }
                        heightStr = [NSString stringWithFormat:@"ceil(%@.height)",calSizeName];
                    }
                    
                    [strArray replaceObjectAtIndex:2 withObject:widthStr];
                    [strArray replaceObjectAtIndex:3 withObject:heightStr];

                    NSString *str = [layout stringByReplacingCharactersInRange:NSMakeRange(result.range.location + rectPrefix.length+1, result.range.length - rectPrefix.length-2) withString:[strArray componentsJoinedByString:@", "]];
                    if (sizeRange.location != NSNotFound) {
                        if (sizeFit.length > 0) {
                            NSString *fitStr = [sizeFit stringByReplacingCharactersInRange:NSMakeRange(sizeRange.location + sizePrefix.length+1, sizeRange.length - sizePrefix.length-2) withString:[sizeValues componentsJoinedByString:@", "]];
                            [layoutsArray addObject:fitStr];
                            sizeFit = nil;
                        } else {
                            str = [str stringByReplacingCharactersInRange:NSMakeRange(sizeRange.location + sizePrefix.length+1, sizeRange.length - sizePrefix.length-2) withString:[sizeValues componentsJoinedByString:@", "]];
                        }
                    }
                    [layoutsArray addObject:str];
                    if (properties.count == 0) {
                        [properties addObject:property];
                    } else {
                        [properties insertObject:property atIndex:index];
                    }
                    [frameDic setObject:[NSValue valueWithCGRect:frame] forKey:property.name];
                    isFind = YES;
                    isLayout = YES;
                    *stop = YES;
                }
            }];
            if (!isLayout) {
                __block BOOL isSizeFit = NO;
                [sizeRegex enumerateMatchesInString:layout options:NSMatchingReportProgress range:NSMakeRange(0, layout.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                    if (result) {
                        isSizeFit = YES;
                        *stop = YES;
                    }
                }];
                if (isSizeFit) {
                    sizeFit = layout;
                } else {
                    [layoutsArray addObject:layout];
                }
            }
        }
        property.layout = layoutsArray;
        if (!isFind) {
            [properties addObject:property];
        }
    }
    
    regexString = @"\\s*[^,]*\\s*";
    regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"CGRectMake\\(%@,%@,%@,%@\\)",regexString,regexString,regexString,regexString] options:NSRegularExpressionCaseInsensitive error:nil];
    
    [[self class] adjustTop:properties frameDic:frameDic regex:regex sizeRegex:sizeRegex];
    [[self class] adjustLeft:properties frameDic:frameDic regex:regex sizeRegex:sizeRegex];
    
    return properties;
}

+ (NSArray<YLPropertyT *> *)adjustTop:(NSArray<YLPropertyT *> *)properties
                             frameDic:(NSDictionary<NSString *, NSValue *> *)frameDic
                                regex:(NSRegularExpression *)regex
                                sizeRegex:(NSRegularExpression *)sizeRegex {
    YLPropertyT *property = nil;
    NSValue *value = nil;
    NSString *rectPrefix = @"CGRectMake";
    NSString *sizePrefix = @"sizeThatFits:CGSizeMake";
    __block CGRect lastFrame = CGRectZero;
    for (NSInteger i=1; i<properties.count; i++) {
        if (!property) {
            property = [properties objectAtIndex:i-1];
        }
        if (!value) {
            value = [frameDic objectForKey:property.name];
        }
        if (!value || !property) {
            value = nil;
            property = nil;
            continue;
        }
        CGRect frame = [value CGRectValue];
        if (CGRectEqualToRect(lastFrame, CGRectZero)) {
            lastFrame = frame;
            if (property.topMargin == 0) {
                property.topMargin = CGRectGetMinY(frame);
            }
        }
        YLPropertyT *next = [properties objectAtIndex:i];
        NSValue *value1 = [frameDic objectForKey:next.name];
        if (!value1) {
            continue;
        }
        if (value1) {
            CGRect frame1 = [value1 CGRectValue];
            NSMutableArray *layoutsArray = [NSMutableArray array];
            for (NSInteger k=0; k<next.layout.count; k++) {
                NSString *layout = [next.layout objectAtIndex:k];
                __block BOOL isFind = NO;
                [regex enumerateMatchesInString:layout options:NSMatchingReportProgress range:NSMakeRange(0, layout.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                    if (result) {
                        
                        NSString *value = [layout substringWithRange:NSMakeRange(result.range.location + rectPrefix.length + 1, result.range.length - rectPrefix.length - 2)];
                        value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSArray<NSString *> *values = [value componentsSeparatedByString:@","];
                        NSMutableArray *strArray = [NSMutableArray arrayWithArray:values];
                        
                        __block NSRange sizeRange = NSMakeRange(NSNotFound, 0);
                        [sizeRegex enumerateMatchesInString:layout options:NSMatchingReportProgress range:NSMakeRange(0, layout.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                            if (result) {
                                sizeRange = result.range;
                                *stop = YES;
                            }
                        }];
                        
                        NSString *topStr = [strArray objectAtIndex:1];
                        if (CGRectContainsRect(lastFrame, frame1)) {
                            next.calculateSize = nil;
                        } else if (CGRectIntersectsRect(lastFrame, frame1)) {
                            next.topMargin = (CGRectGetMinY(frame1)-CGRectGetMinY(lastFrame));
                            lastFrame = frame1;
                        } else {
                            next.topMargin = (CGRectGetMinY(frame1)-CGRectGetMaxY(lastFrame));
                            lastFrame = frame1;
                        }
                        
                        CGFloat topMargin = (CGRectGetMinY(frame1)-CGRectGetMinY(frame));
                        NSString *lastTop = [NSString stringWithFormat:@"CGRectGetMinY(_%@.frame) + ",property.name];
                        
                        if (CGRectIntersectsRect(frame, frame1)) {
                            if (CGRectGetMinY(frame) == 0) {
                                lastTop = @"";
                            }
                            if (fabs(((CGRectGetHeight(frame) - CGRectGetHeight(frame1))/2 - topMargin)) <= 5) {
                                topStr = [NSString stringWithFormat:@"(%@ (CGRectGetHeight(_%@.frame)-%@)/2)",lastTop, property.name, [values lastObject]];
                            } else {
                                if (lastTop.length == 0) {
                                    topStr = [NSString stringWithFormat:@"%.1f", topMargin];
                                } else {
                                    topStr = [NSString stringWithFormat:@"(%@ %.1f)", lastTop, topMargin];
                                }
                            }
                        } else {
                            if (CGRectGetMinY(frame1) > CGRectGetMinY(frame) && CGRectGetMinY(frame1) < CGRectGetMaxY(frame)) {
                                if (fabs(((CGRectGetHeight(frame) - CGRectGetHeight(frame1))/2 - topMargin)) <= 5) {
                                    topStr = [NSString stringWithFormat:@"(%@ (CGRectGetHeight(_%@.frame)-%@)/2)",lastTop, property.name, [values lastObject]];
                                    if ([property.calculateSize containsString:sizePrefix]) {
                                        next.calculateSize = [NSString stringWithFormat:@"MAX(%@_size.height, %@)",property.name,next.calculateSize];
                                    } else if ([next.calculateSize containsString:sizePrefix]) {
                                        NSString *calStr = next.calculateSize;
                                        next.calculateSize = [NSString stringWithFormat:@"MAX(%@, %@_size.height)",property.calculateSize,next.name];
                                        property.calculateSize = calStr;
                                        property.isOnlyCalculate = YES;
                                    } else if (property.calculateSize && next.calculateSize) {
                                        next.calculateSize = [NSString stringWithFormat:@"MAX(%@, %@)",property.calculateSize,next.calculateSize];
                                        property.calculateSize = nil;
                                    }
                                } else {
                                    if (lastTop.length == 0) {
                                        topStr = [NSString stringWithFormat:@"%.1f", topMargin];
                                    } else {
                                        topStr = [NSString stringWithFormat:@"(%@ %.1f)", lastTop, topMargin];
                                    }
                                }
                            } else {
                                if (CGRectGetMinY(frame1) < CGRectGetMinY(frame)) {
                                    topStr = [NSString stringWithFormat:@"%.1f", CGRectGetMinY(frame1)];
                                } else {
                                    topStr = [NSString stringWithFormat:@"(CGRectGetMaxY(_%@.frame) + %.1f)",property.name, (frame1.origin.y-frame.origin.y-frame.size.height)];
                                }
                            }
                        }
                        [strArray replaceObjectAtIndex:1 withObject:topStr];
                                                    
                        NSString *str = [layout stringByReplacingCharactersInRange:NSMakeRange(result.range.location + rectPrefix.length + 1, result.range.length - rectPrefix.length - 2) withString:[strArray componentsJoinedByString:@", "]];
                        NSLog(@"%@",str);
                        [layoutsArray addObject:str];
                        isFind = YES;
                        *stop = YES;
                    }
                }];
                if (!isFind) {
                    [layoutsArray addObject:layout];
                }
            }
            next.layout = layoutsArray;
            property = next;
            value = value1;
        }
    }
    return properties;
}

+ (NSArray<YLPropertyT *> *)adjustLeft:(NSArray<YLPropertyT *> *)properties
                              frameDic:(NSDictionary<NSString *, NSValue *> *)frameDic
                                 regex:(NSRegularExpression *)regex
                             sizeRegex:(NSRegularExpression *)sizeRegex {
    NSString *rectPrefix = @"CGRectMake";
    NSString *sizePrefix = @"sizeThatFits:CGSizeMake";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:frameDic copyItems:YES];
    for (NSInteger i=0; i<properties.count-1; i++) {
        YLPropertyT *property = [properties objectAtIndex:i];
        NSValue *value = [dic objectForKey:property.name];
        if (value) {
            __block CGRect frame = [value CGRectValue];
            __block NSString  *leftStr = [NSString stringWithFormat:@"CGRectGetMinX(_%@.frame)",property.name];
            __block YLPropertyT *same = property;
            for (NSInteger j=i+1; j<properties.count; j++) {
                YLPropertyT *follow = [properties objectAtIndex:j];
                NSValue *value1 = [dic objectForKey:follow.name];
                if (value1) {
                    CGRect frame1 = [value1 CGRectValue];
                    __block NSString *sizeFit = nil;
                    NSMutableArray *layoutsArray = [NSMutableArray array];
                    for (NSInteger k=0; k<follow.layout.count; k++) {
                        NSString *layout = [follow.layout objectAtIndex:k];
                        __block BOOL isFind = NO;
                        [regex enumerateMatchesInString:layout options:NSMatchingReportProgress range:NSMakeRange(0, layout.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                            if (result) {
                                NSString *value = [layout substringWithRange:NSMakeRange(result.range.location + rectPrefix.length+1, result.range.length - rectPrefix.length-2)];
                                value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
                                NSArray<NSString *> *values = [value componentsSeparatedByString:@","];
                                NSMutableArray *strArray = [NSMutableArray arrayWithArray:values];
                                
                                __block NSString *width = [strArray objectAtIndex:2];
                                if (CGRectGetWidth(frame) == CGRectGetWidth(frame1)) {
                                    width = [NSString stringWithFormat:@"CGRectGetWidth(_%@.frame)",same.name];
                                }
                                else {
                                    NSString *symmetry = [NSString stringWithFormat:@"(2*%.1f)",ceil(frame.origin.x)];
                                    if ([width containsString:symmetry]) {
                                        width = [width stringByReplacingOccurrencesOfString:symmetry withString:[NSString stringWithFormat:@"(2*%@)",leftStr]];
                                    }
                                }
                                
                                __block NSRange sizeRange = NSMakeRange(NSNotFound, 0);
                                __block NSMutableArray<NSString *> *sizeValues = nil;
                                
                                if (CGRectGetMinX(frame1) == CGRectGetMinX(frame)) {
                                    
                                    [sizeRegex enumerateMatchesInString:layout options:NSMatchingReportProgress range:NSMakeRange(0, layout.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                        if (result) {
                                            sizeRange = result.range;
                                            NSString *sizeStr = [layout substringWithRange:NSMakeRange(result.range.location + sizePrefix.length + 1, result.range.length - sizePrefix.length - 2)];
                                            NSString *sizeValue = [sizeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                                            sizeValues = [NSMutableArray arrayWithArray:[sizeValue componentsSeparatedByString:@","]];
                                            [sizeValues replaceObjectAtIndex:0 withObject:width];
                                            *stop = YES;
                                        }
                                    }];
                                    if (sizeRange.location == NSNotFound && sizeFit.length > 0) {
                                        [sizeRegex enumerateMatchesInString:sizeFit options:NSMatchingReportProgress range:NSMakeRange(0, sizeFit.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                            if (result) {
                                                sizeRange = result.range;
                                                NSString *sizeStr = [sizeFit substringWithRange:NSMakeRange(result.range.location + sizePrefix.length + 1, result.range.length - sizePrefix.length - 2)];
                                                NSString *sizeValue = [sizeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                                                sizeValues = [NSMutableArray arrayWithArray:[sizeValue componentsSeparatedByString:@","]];
                                                [sizeValues replaceObjectAtIndex:0 withObject:width];
                                                *stop = YES;
                                            }
                                        }];
                                    }
                                    
                                    if (follow.calculateSize) {
                                        [sizeRegex enumerateMatchesInString:follow.calculateSize options:NSMatchingReportProgress range:NSMakeRange(0, follow.calculateSize.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                            if (result) {
                                                NSString *sizeStr = [follow.calculateSize substringWithRange:NSMakeRange(result.range.location + sizePrefix.length + 1, result.range.length - sizePrefix.length - 2)];
                                                NSString *sizeValue = [sizeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                                                NSMutableArray<NSString *> *calValues = [NSMutableArray arrayWithArray:[sizeValue componentsSeparatedByString:@","]];

                                                [calValues replaceObjectAtIndex:0 withObject:width];
                                                follow.calculateSize = [follow.calculateSize stringByReplacingCharactersInRange:NSMakeRange(result.range.location + sizePrefix.length+1, result.range.length - sizePrefix.length-2) withString:[calValues componentsJoinedByString:@", "]];
                                                *stop = YES;
                                            }
                                        }];
                                    }
                                    
                                    [strArray replaceObjectAtIndex:0 withObject:leftStr];
                                    leftStr = [NSString stringWithFormat:@"CGRectGetMinX(_%@.frame)",follow.name];
                                    
                                    if (sizeRange.location == NSNotFound) {
                                        [strArray replaceObjectAtIndex:2 withObject:width];
                                    }
                                    
                                    same = follow;
                                    frame = frame1;
                                }
                                
                                if (!CGRectContainsRect(frame, frame1) && CGRectGetMinY(frame1) > CGRectGetMinY(frame) && CGRectGetMinY(frame1) < CGRectGetMaxY(frame)) {
                                    NSString *left = [NSString stringWithFormat:@"CGRectGetMaxX(_%@.frame) + %.1f",property.name,(CGRectGetMinX(frame1)-CGRectGetMaxX(frame))];
                                    [strArray replaceObjectAtIndex:0 withObject:left];
                                }
                                NSString *str = [layout stringByReplacingCharactersInRange:NSMakeRange(result.range.location + rectPrefix.length+1, result.range.length - rectPrefix.length-2) withString:[strArray componentsJoinedByString:@", "]];
                                if (sizeRange.location != NSNotFound) {
                                    if (sizeFit.length > 0) {
                                        NSString *fitStr = [sizeFit stringByReplacingCharactersInRange:NSMakeRange(sizeRange.location + sizePrefix.length+1, sizeRange.length - sizePrefix.length-2) withString:[sizeValues componentsJoinedByString:@", "]];
                                        [layoutsArray addObject:fitStr];
                                        sizeFit = nil;
                                    } else {
                                        str = [str stringByReplacingCharactersInRange:NSMakeRange(sizeRange.location + sizePrefix.length+1, sizeRange.length - sizePrefix.length-2) withString:[sizeValues componentsJoinedByString:@", "]];
                                    }
                                }
                                NSLog(@"%@",str);
                                [layoutsArray addObject:str];
                                
                                isFind = YES;
                                *stop = YES;
                            }
                        }];
                        if (!isFind) {
                            __block BOOL isSizeFit = NO;
                            [sizeRegex enumerateMatchesInString:layout options:NSMatchingReportProgress range:NSMakeRange(0, layout.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                if (result) {
                                    isSizeFit = YES;
                                    *stop = YES;
                                }
                            }];
                            if (isSizeFit) {
                                sizeFit = layout;
                            } else {
                                [layoutsArray addObject:layout];
                            }
                            [layoutsArray addObject:layout];
                        }
                    }
                    follow.layout = layoutsArray;
                }
            }
        }
    }
    return properties;
}

+ (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

+ (NSArray<YLPropertyT *> *)adjustLayoutRelation:(YLPSDLayerRecordInfo *)record {
    NSArray<YLPropertyT *> *array = [[self class] getPointsRelation:record frame:record.classView.frame];
    return array;
}

+ (NSString *)getViewName:(NSString *)content {
    NSString *viewName = nil;
    NSArray *array = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in array) {
        if ([line containsString:@"setFrame:CGRectMake("]) {
            NSInteger nameEnd = [line rangeOfString:@"setFrame:CGRectMake("].location - 1;
            NSInteger nameStart = nameEnd - 1;
            unichar letter = [line characterAtIndex:nameStart];
            while (letter != '\n' && letter != '.' && letter != '_' && nameStart >= 0) {
                nameStart--;
            }
            viewName = [content substringWithRange:NSMakeRange(nameStart + 1, nameEnd - nameStart - 1)];
            break;
        }
    }
    return viewName;
}

@end
