//
//  YLPSDEngineData.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDEngineData.h"

@implementation YLPSDEngineData

//https://psd-tools2.readthedocs.io/en/stable/_modules/psd_tools2/psd/engine_data.html#String
- (NSDictionary *)parseEngineData:(unsigned char *)tdta length:(NSInteger)length {
    
//    NSString *test = [[NSString alloc] initWithBytes:tdta length:length encoding:NSASCIIStringEncoding];
    
    NSString *temp;
    [self bytesToJson:tdta length:length child:&temp appendEnd:YES];
    NSMutableString *json = [[NSMutableString alloc] initWithString:temp];
    
    if (json.length > 2 && [[json substringWithRange:NSMakeRange(json.length-2, 1)] isEqualToString:@","]) {
        [json deleteCharactersInRange:NSMakeRange(json.length-2, 1)];
    }
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    return jsonDict;
//    NSLog(@"%@,%@",json,string);
}

//- (NSInteger)bytesToJson:(unsigned char[])bytes length:(NSInteger)length child:(NSString **)child appendEnd:(BOOL)append {
//    NSInteger index = 0;
//    NSInteger lastIndex = 0;
//    NSInteger startIndex = 0;
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSMutableString *json = [[NSMutableString alloc] init];
//    NSMutableData *tempData = [[NSMutableData alloc] init];
//    while (index < (length + (append?1:0))) {
//        if (index == length || ((index < length) && (bytes[index] == '\n'))) {
//            if (startIndex < index) {
//                NSString *string = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//                string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//                string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//                if (string.length > 0) {
//                    BOOL isCustom = NO;
//                    if ([string isEqualToString:@"<<"]) {
//                        [json appendString:@"{\n"];
//                        NSInteger count = length - (index + 1);
//                        unsigned char indexData[count];
//                        for (NSInteger i=0; i<count; i++) {
//                            indexData[i] = bytes[index + i + 1];
//                        }
//                        NSString *childJson;
//                        NSInteger skipLength = [self bytesToJson:indexData length:count child:&childJson appendEnd:YES];
//                        if (childJson.length > 0) {
//                            [json appendString:childJson];
//                        }
//                        index += skipLength;
//                    } else if ([string isEqualToString:@">>"]) {
//                        if (json.length > 2
//                            && [[json substringWithRange:NSMakeRange(json.length-2, 1)] isEqualToString:@","]) {
//                            [json deleteCharactersInRange:NSMakeRange(json.length-2, 1)];
//                        }
//                        [json appendString:@"},\n"];
//                        break;
//                    } else if ([string containsString:@"["] && [string containsString:@"]"]) {
//                        NSArray *array = [string componentsSeparatedByString:@" "];
//                        NSUInteger bracketOpenIndex = [array indexOfObject:@"["];
//                        NSUInteger bracketCloseIndex = [array indexOfObject:@"]"];
//                        if (array.count > 0) {
//                            if (bracketOpenIndex > 0) {
//                                if ([array[0] hasPrefix:@"/"]) {
//                                    [json appendFormat:@"\"%@\":",[array[0] substringFromIndex:1]];
//                                } else {
//                                    [json appendFormat:@"\"%@\":",array[0]];
//                                }
//                            } else {
//                                [json appendFormat:@"%@\n",array[0]];
//                            }
//                        }
//                        if (array.count > 1) {
//                            for (NSInteger i=1; i<array.count; i++) {
//                                if (bracketOpenIndex == i) {
//                                    [json appendFormat:@"%@\n",array[i]];
//                                } else if (bracketCloseIndex == i) {
//                                    if (json.length > 2
//                                        && [[json substringWithRange:NSMakeRange(json.length-2, 1)] isEqualToString:@","]) {
//                                        [json deleteCharactersInRange:NSMakeRange(json.length-2, 1)];
//                                    }
//                                    [json appendFormat:@"%@,\n",array[i]];
//                                } else {
//                                    [json appendFormat:@"\"%@\",\n",array[i]];
//                                }
//                            }
//                        }
//                    } else if ([string containsString:@"["]) {
//                        NSArray *array = [string componentsSeparatedByString:@" "];
//                        NSUInteger bracketOpenIndex = [array indexOfObject:@"["];
//                        if (bracketOpenIndex == NSNotFound) {
//                            isCustom = YES;
//                        } else {
//                            if (array.count > 0) {
//                                if (bracketOpenIndex > 0) {
//                                    if ([array[0] hasPrefix:@"/"]) {
//                                        [json appendFormat:@"\"%@\":",[array[0] substringFromIndex:1]];
//                                    } else {
//                                        [json appendFormat:@"\"%@\":",array[0]];
//                                    }
//                                } else {
//                                    [json appendFormat:@"%@\n",array[0]];
//                                }
//                            }
//                            if (array.count > 1) {
//                                for (NSInteger i=1; i<array.count; i++) {
//                                    if (bracketOpenIndex == i) {
//                                        [json appendFormat:@"%@\n",array[i]];
//                                    } else {
//                                        [json appendFormat:@"\"%@\",\n",array[i]];
//                                    }
//                                }
//                            }
//                        }
//                    } else if ([string containsString:@"]"]) {
//                        NSArray *array = [string componentsSeparatedByString:@" "];
//                        NSUInteger bracketCloseIndex = [array indexOfObject:@"]"];
//                        if (bracketCloseIndex == NSNotFound) {
//                            isCustom = YES;
//                        } else {
//                            if (array.count > 0) {
//                                if (bracketCloseIndex > 0) {
//                                    if ([array[0] hasPrefix:@"/"]) {
//                                        [json appendFormat:@"\"%@\":",[array[0] substringFromIndex:1]];
//                                    } else {
//                                        [json appendFormat:@"\"%@\":",array[0]];
//                                    }
//                                } else {
//                                    if (json.length > 2
//                                        && [[json substringWithRange:NSMakeRange(json.length-2, 1)] isEqualToString:@","]) {
//                                        [json deleteCharactersInRange:NSMakeRange(json.length-2, 1)];
//                                    }
//                                    [json appendFormat:@"%@,\n",array[0]];
//                                }
//                            }
//                            if (array.count > 1) {
//                                for (NSInteger i=1; i<array.count; i++) {
//                                    if (bracketCloseIndex == i) {
//                                        if (json.length > 2
//                                            && [[json substringWithRange:NSMakeRange(json.length-2, 1)] isEqualToString:@","]) {
//                                            [json deleteCharactersInRange:NSMakeRange(json.length-2, 1)];
//                                        }
//                                        [json appendFormat:@"%@,\n",array[i]];
//                                    } else {
//                                        [json appendFormat:@"\"%@\",\n",array[i]];
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        isCustom = YES;
//                    }
//
//                    if (isCustom) {
//                        NSArray *array = [string componentsSeparatedByString:@" "];
//                        if (array.count > 0) {
//                            if ([array[0] hasPrefix:@"/"]) {
//                                NSString *title = [array[0] substringFromIndex:1];
//                                [json appendFormat:@"\"%@\":",title];
//                                if (array.count > 1) {
//                                    [json appendString:@"\""];
//                                    if ([string containsString:@"("] && [string containsString:@")"]) {
//                                        unsigned char origin[data.length];
//                                        [data getBytes:&origin length:data.length];
//                                        NSInteger parenthesisOpenIndex = 0;
//                                        NSInteger parenthesisCloseIndex = 0;
//                                        for (NSInteger i=1; i<data.length; i++) {
//                                            if (origin[i] == '(') {
//                                                parenthesisOpenIndex = i;
//                                                if (i < data.length-2) {
//                                                    if (origin[i+1] == 0XFE && origin[i+2] == 0XFF) {
//                                                        parenthesisOpenIndex += 2;
//                                                    } else {
//                                                        break;
//                                                    }
//                                                }
//                                            } else if (origin[i] == ')') {
//                                                parenthesisCloseIndex = i;
//                                            } else if (parenthesisOpenIndex > 0
//                                                       && i > parenthesisOpenIndex
//                                                       && parenthesisCloseIndex == 0) {
//                                                if (origin[i-1] == '\\' && origin[i] == '\\') {
//
//                                                } else {
//                                                    [tempData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
//                                                }
//                                            }
//                                        }
//                                        if (parenthesisOpenIndex < parenthesisCloseIndex) {
//                                            string = [[[NSString alloc] initWithData:tempData encoding:NSUnicodeStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//                                            string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//                                            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                                            tempData = [[NSMutableData alloc] init];
//                                            if ([title isEqualToString:@"NoStart"]
//                                                || [title isEqualToString:@"NoEnd"]
//                                                || [title isEqualToString:@"Keep"]
//                                                || [title isEqualToString:@"Hanging"]) {
//
//                                            } else {
//                                                [json appendString:string];
//                                            }
//                                        }
//                                    } else if ([string containsString:@"("]) {
//                                        unsigned char origin[data.length];
//                                        [data getBytes:&origin length:data.length];
//                                        NSInteger parenthesisOpenIndex = 0;
//                                        for (NSInteger i=1; i<data.length; i++) {
//                                            if (origin[i] == '(') {
//                                                parenthesisOpenIndex = i;
//                                                if (i < data.length-2) {
//                                                    if (origin[i+1] == 0XFE && origin[i+2] == 0XFF) {
//                                                        parenthesisOpenIndex += 2;
//                                                    } else {
//                                                        break;
//                                                    }
//                                                }
//                                            }
//                                            if (parenthesisOpenIndex > 0) {
//                                                if (origin[i-1] == '\\' && origin[i] == '\\') {
//
//                                                } else {
//                                                    [tempData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
//                                                }
//                                            }
//                                        }
//                                    } else if ([string containsString:@")"]) {
//                                        unsigned char origin[data.length];
//                                        [data getBytes:&origin length:data.length];
//                                        NSInteger parenthesisCloseIndex = 0;
//                                        for (NSInteger i=1; i<data.length; i++) {
//                                            if (origin[i] == ')') {
//                                                parenthesisCloseIndex = i;
//                                            } else if (parenthesisCloseIndex == 0) {
//                                                if (origin[i-1] == '\\' && origin[i] == '\\') {
//
//                                                } else {
//                                                    [tempData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
//                                                }
//                                            }
//                                        }
//                                        string = [[[NSString alloc] initWithData:tempData encoding:NSUnicodeStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//                                        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//                                        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                                        tempData = [[NSMutableData alloc] init];
//                                    } else {
//                                        for (NSInteger i=1; i<array.count; i++) {
//                                            [json appendFormat:@"%@",array[i]];
//                                        }
//                                    }
//                                    [json appendString:@"\",\n"];
//                                }
//                            } else {
//                                if (json.length > 3
//                                    && [[json substringWithRange:NSMakeRange(json.length-3, 3)] isEqualToString:@"\",\n"]) {
//                                    [json deleteCharactersInRange:NSMakeRange(json.length-3, 3)];
//                                }
//                                if (tempData.length > 0 && [string containsString:@")"]) {
//                                    unsigned char origin[data.length];
//                                    [data getBytes:&origin length:data.length];
//                                    NSInteger parenthesisCloseIndex = 0;
//                                    for (NSInteger i=1; i<data.length; i++) {
//                                        if (origin[i] == ')') {
//                                            parenthesisCloseIndex = i;
//                                        } else if (parenthesisCloseIndex == 0) {
//                                            if (origin[i-1] == '\\' && origin[i] == '\\') {
//
//                                            } else {
//                                                [tempData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
//                                            }
//                                        }
//                                    }
//                                    string = [[[NSString alloc] initWithData:tempData encoding:NSUnicodeStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//                                    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//                                    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                                    tempData = [[NSMutableData alloc] init];
//                                } else {
//                                    [json appendString:string];
//                                }
//                                [json appendString:@"\",\n"];
//                            }
//                        }
//
////                        NSLog(@"~~~~~~%@~~~~~~\n",string);
//                    }
//                }
//                data = [[NSMutableData alloc] init];
//            }
//            lastIndex = index;
//        } else {
//            unsigned char indexData[1];
//            indexData[0] = bytes[index];
//            [data appendBytes:indexData length:1];
//        }
//        index++;
//    }
//    *child = json;
//    return index;
//}

- (NSInteger)bytesToJson:(unsigned char[])bytes length:(NSInteger)length child:(NSString **)child appendEnd:(BOOL)append {
    NSInteger index = 0;
    NSInteger lastIndex = 0;
    NSInteger startIndex = 0;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSMutableString *json = [[NSMutableString alloc] init];
    NSMutableData *tempData = [[NSMutableData alloc] init];

    while (index < (length + (append?1:0))) {
        if (index == length || ((index < length) && (bytes[index] == '\n'))) {
            if (startIndex < index) {
                NSString *originString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                NSString *string = [originString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                if (string.length > 0) {
                    
                    BOOL isCustom = NO;
                    if ([string isEqualToString:@"<<"]) {
                        [json appendString:@"{\n"];
                        NSInteger count = length - (index + 1);
                        unsigned char indexData[count];
                        for (NSInteger i=0; i<count; i++) {
                            indexData[i] = bytes[index + i + 1];
                        }
                        NSString *childJson;
                        NSInteger skipLength = [self bytesToJson:indexData length:count child:&childJson appendEnd:YES];
                        if (childJson.length > 0) {
                            [json appendString:childJson];
                        }
                        index += skipLength;
                    } else if ([string isEqualToString:@">>"]) {
                        if (json.length > 2
                            && [[json substringWithRange:NSMakeRange(json.length-2, 1)] isEqualToString:@","]) {
                            [json deleteCharactersInRange:NSMakeRange(json.length-2, 1)];
                        }
                        [json appendString:@"},\n"];
                        break;
                    } else if ([string containsString:@"["] && [string containsString:@"]"]) {
                        if ([string containsString:@"("] && [string containsString:@")"]) {
                            isCustom = YES;
                        } else {
                            NSString *value = [self parseArrayString:data leaveData:&tempData];
                            if (value) {
                               [json appendString:value];
                               if (json.length > 5
                                   && [[json substringWithRange:NSMakeRange(json.length-5, 1)] isEqualToString:@","]) {
                                   [json deleteCharactersInRange:NSMakeRange(json.length-5, 1)];
                               }
                            } else {
//                               NSLog(@"~~~~~~~~~~~");
                            }
                        }
                    } else if ([string hasSuffix:@"["] || [string hasSuffix:@"]"]) {
                        NSString *value = [self parseArrayString:data leaveData:&tempData];
                        if (value) {
                           [json appendString:value];
                           if (json.length > 5
                               && [[json substringWithRange:NSMakeRange(json.length-5, 1)] isEqualToString:@","]) {
                               [json deleteCharactersInRange:NSMakeRange(json.length-5, 1)];
                           }
                        } else {
//                           NSLog(@"~~~~~~~~~~~");
                        }
                    } else {
                        isCustom = YES;
                    }
                    
                    if (isCustom) {
                        NSString *value = [self parseString:data leaveData:&tempData];
                        if (value) {
                            [json appendString:value];
                        } else {
//                            NSLog(@"~~~~~~~~~~~");
                        }
//                      NSLog(@"~~~~~~%@~~~~~~\n",string);
                    }
                }
                data = [[NSMutableData alloc] init];
            }
            lastIndex = index;
        } else {
            unsigned char indexData[1];
            indexData[0] = bytes[index];
            [data appendBytes:indexData length:1];
        }
        index++;
    }
    *child = json;
    return index;
}

- (NSString *)parseString:(NSData *)data leaveData:(NSMutableData **)leaveData {
    
    NSMutableData *appendData = [[NSMutableData alloc] init];
    if (leaveData && (*leaveData).length > 0) {
        NSMutableData *tempData = [NSMutableData dataWithData:*leaveData];
        [tempData appendData:data];
        data = tempData;
        *leaveData = [NSMutableData data];
    }
    NSString *string = nil;
    
    NSInteger startIndex;
    string = [self parseKeyString:data endIndex:&startIndex];
    
    NSInteger parenthesisOpenIndex = -1;
    NSInteger parenthesisCloseIndex = 0;
    
    NSInteger lastCloseIndex = parenthesisCloseIndex;
    unsigned char origin[data.length];
    [data getBytes:&origin length:data.length];
    
    NSInteger transCount = 0;
    
    NSMutableArray *texts = [NSMutableArray array];
        
    for (NSInteger i=startIndex; i<data.length; i++) {
        if (origin[i] == '(' && parenthesisOpenIndex == -1) {
            parenthesisOpenIndex = i;
            if (i < data.length - 2) {
                if (origin[i+1] == 0XFE && origin[i+2] == 0XFF) {
                    parenthesisOpenIndex += 2;
                    if (parenthesisCloseIndex > 0) {
                        NSString *prefix = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(parenthesisCloseIndex, parenthesisOpenIndex-parenthesisCloseIndex-2)] encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                        [texts addObject:prefix];
                    }
                    else if ((int)(parenthesisOpenIndex - startIndex - 2) > 0) {
                        NSString *prefix = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(startIndex, parenthesisOpenIndex-startIndex-2)] encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                        [texts addObject:prefix];
                    }
                } else {
                    break;
                }
            }
        } else if (origin[i] == ')') {
            if (transCount > 0) {
                transCount = 0;
                [appendData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
            } else {
                parenthesisCloseIndex = i;
                if (parenthesisOpenIndex >= startIndex && parenthesisOpenIndex < parenthesisCloseIndex) {
                    if (transCount > 0) {
                        transCount = 0;
                        unsigned char trans[1] = {0};
                        trans[0] = '\\';
                        [appendData appendBytes:trans length:sizeof(trans)];
                    }
                    NSString *text = [[NSString alloc] initWithData:appendData encoding:NSUnicodeStringEncoding];
//                    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    while (text.length > 0
                           && ([[text substringFromIndex:(text.length-1)] isEqual:@"\0"]
                           || [[text substringFromIndex:(text.length-1)] isEqual:@"\r"])) {
                        if (text.length > 1) {
                            text = [text substringToIndex:(text.length-1)];
                        } else {
                            text = nil;
                            break;
                        }
                    }
//                    text = [text stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@"*#r#*"];
                    if (text) {
                        [texts addObject:text];
                    }
                    lastCloseIndex = parenthesisCloseIndex;
                    appendData = [NSMutableData data];
                    parenthesisOpenIndex = -1;
                    parenthesisCloseIndex = 0;
                }
            }
        } else if (parenthesisOpenIndex >= 0
               && i > parenthesisOpenIndex
               && parenthesisCloseIndex == 0) {
            if (origin[i] != '\\') {
                transCount = 0;
                [appendData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
            } else {
                transCount++;
                if (transCount == 2) {
                    transCount = 0;
                    [appendData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
                }
            }
        } else if (origin[i] == '\t') {
            continue;
        }
    }
    
    if (lastCloseIndex > 0) {
        string = [string?:@"" stringByAppendingString:@"\""];
        for (NSString *text in texts) {
            string = [string stringByAppendingString:text];
        }
        if (lastCloseIndex < data.length - 1) {
            NSString *suffix = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(lastCloseIndex + 1, data.length-lastCloseIndex-1)] encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            string = [string stringByAppendingString:suffix];
        }
        string = [string stringByAppendingString:@"\",\n"];
    } else if (parenthesisOpenIndex >= startIndex) {
        *leaveData = [NSMutableData dataWithData:data];
        return nil;
    } else if ((int)(data.length - startIndex) > 0) {
        NSString *value = [self parseValueString:[data subdataWithRange:NSMakeRange(startIndex, data.length-startIndex)] startIndex:0];
        string = [string?:@"" stringByAppendingString:value];
    }
    if ([string containsString:@"NoStart"] || [string containsString:@"NoEnd"]) {
        return nil;
    }
    return string;
}

- (NSString *)parseValueString:(NSData *)data startIndex:(NSInteger)startIndex {
    unsigned char origin[data.length];
    [data getBytes:&origin length:data.length];
    
    NSString *string = @"\"";
    NSInteger beginIndex = startIndex;
    for (NSInteger i=startIndex; i<data.length; i++) {
        if (origin[i] == ' ') {
            NSString *value = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(beginIndex, i-beginIndex)] encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            if (value.length > 0) {
                string = [string stringByAppendingString:value];
                if (i != data.length - 1) {
                    string = [string stringByAppendingString:@"\",\n\""];
                }
            }
            beginIndex = i + 1;
        } else if (i == data.length - 1) {
            NSString *value = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(beginIndex, i-beginIndex+1)] encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            if (value.length > 0) {
                string = [string stringByAppendingString:value];
            }
        }
    }
    string = [string stringByAppendingString:@"\",\n"];
    return string;
}

- (NSString *)parseArrayString:(NSData *)data leaveData:(NSMutableData **)leaveData {
    
    NSMutableData *appendData = [[NSMutableData alloc] init];
    if ((*leaveData).length > 0) {
        NSMutableData *tempData = [NSMutableData dataWithData:*leaveData];
        [tempData appendData:data];
        data = tempData;
        *leaveData = [NSMutableData data];
    }
    NSString *string = nil;
    
    NSInteger startIndex;
    string = [self parseKeyString:data endIndex:&startIndex];
    
    NSInteger parenthesisOpenIndex = -1;
    NSInteger parenthesisCloseIndex = 0;
    
    NSInteger lastCloseIndex = parenthesisCloseIndex;
    unsigned char origin[data.length];
    [data getBytes:&origin length:data.length];
    
    NSMutableArray *texts = [NSMutableArray array];
        
    for (NSInteger i=startIndex; i<data.length; i++) {
        if (origin[i] == '[' && parenthesisOpenIndex == -1) {
            if (parenthesisCloseIndex > 0) {
                NSString *text = [self parseString:[data subdataWithRange:NSMakeRange(parenthesisCloseIndex, parenthesisOpenIndex-parenthesisCloseIndex-2)] leaveData:nil];
                if (text.length > 0) {
                    [texts addObject:text];
                }
            }
            else if ((int)(parenthesisOpenIndex - startIndex - 2) > 0) {
                NSString *text = [self parseString:[data subdataWithRange:NSMakeRange(startIndex, parenthesisOpenIndex-startIndex-2)] leaveData:nil];
                if (text.length > 0) {
                    [texts addObject:text];
                }
            }
            parenthesisOpenIndex = i;
            [texts addObject:@"[\n"];
        } else if (origin[i] == ']') {
            parenthesisCloseIndex = i;
            NSString *text = [self parseString:appendData leaveData:nil];
            if (text) {
                if (text.length > 2
                    && [[text substringWithRange:NSMakeRange(text.length-2, 1)] isEqualToString:@","]) {
                    text = [text substringToIndex:text.length-2];
                    text = [text stringByAppendingString:@"\n"];
                }
                [texts addObject:text];
            } else {
//                NSLog(@"~~~~~~~~~~~");
            }
            [texts addObject:@"],\n"];
            lastCloseIndex = parenthesisCloseIndex;
            appendData = [NSMutableData data];
            parenthesisOpenIndex = -1;
            parenthesisCloseIndex = 0;
        } else if (parenthesisOpenIndex >= 0
               && i > parenthesisOpenIndex
               && parenthesisCloseIndex == 0) {
            [appendData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
        } else if (origin[i] == '\t') {
            continue;
        }
    }
    
    if (texts.count > 0) {
        for (NSString *text in texts) {
            string = [string?:@"" stringByAppendingString:text];
        }
    } else if (parenthesisOpenIndex >= startIndex) {
        if (leaveData) {
            *leaveData = [NSMutableData dataWithData:data];
        }
        return nil;
    } else if ((int)(data.length - startIndex) > 0) {
        NSString *value = [self parseValueString:[data subdataWithRange:NSMakeRange(startIndex, data.length-startIndex)] startIndex:0];
        string = [string?:@"" stringByAppendingString:value];
    }
    return string;
}

- (NSString *)parseKeyString:(NSData *)data endIndex:(NSInteger *)endIndex {

    NSInteger startIndex = -1;
    NSMutableData *appendData = [[NSMutableData alloc] init];
    unsigned char origin[data.length];
    [data getBytes:&origin length:data.length];
    
    for (NSInteger i=0; i<data.length; i++) {
        if (origin[i] == '\t' && startIndex == -1) {
            continue;
        }
        if (origin[i] == '/') {
            startIndex = i;
        } else if (origin[i] == ' ') {
            if (endIndex) {
                *endIndex = i;
            }
            break;
        } else if (startIndex >= 0) {
            if (origin[i-1] == '\\' && origin[i] == '\\') {

            } else {
                [appendData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
            }
            if (i == data.length - 1) {
                *endIndex = i;
            }
        }
    }
    
    if (appendData.length > 0) {
        NSString *string = [[[NSString alloc] initWithData:appendData encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (startIndex >= 0) {
            string = [NSString stringWithFormat:@"\"%@\":",string];
        }
        *endIndex = *endIndex + 1;
        return string;
    }
    if (endIndex) {
        *endIndex = 0;
    }
    return nil;
}

@end
