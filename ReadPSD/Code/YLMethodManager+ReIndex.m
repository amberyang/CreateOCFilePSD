//
//  YLMethodManager+ReIndent.m
//  ReadPSD
//
//  Created by amber on 2020/6/15.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLMethodManager+ReIndex.h"

@implementation YLMethodManager (ReIndent)

+ (NSString *)reIndent:(NSString *)content {
    NSInteger index = 0;
    NSString *stringSign = @"";
    NSMutableString *reIndex = [NSMutableString stringWithString:@""];
    BOOL isTrans = NO;
    NSInteger indent = 0;
    BOOL isBegin = NO;
    while (index < content.length) {
        unichar letter = [content characterAtIndex:index];
        if (stringSign.length == 0) {
            if (letter == '{') {
                indent += 4;
            } else if (letter == '}') {
                [reIndex deleteCharactersInRange:NSMakeRange(reIndex.length-4, 4)];
                indent -= 4;
            }
        }
        
        BOOL isContent = YES;
        if (stringSign.length == 0) {
            if (letter == '\n') {
                isBegin = YES;
            } else if (isBegin && (letter == ' ' || letter == '\t')) {
                isContent = NO;
            } else {
                isBegin = NO;
            }
        }
        if (isContent) {
            [reIndex appendString:[NSString stringWithCharacters:&letter length:1]];
        }
        if (indent > 0) {
            if (letter == '@') {
                stringSign = @"@";
                isTrans = NO;
            } else if (letter == '"') {
                if ([stringSign isEqualToString:@"@"]) {
                    stringSign = [stringSign stringByAppendingString:[NSString stringWithCharacters:&letter length:1]];
                } else if (isTrans) {
                    stringSign = [stringSign stringByAppendingString:@"\\\""];
                } else {
                    stringSign = @"";
                    isTrans = NO;
                }
            } else if (letter == '\\' && stringSign.length > 0) {
                isTrans = !isTrans;
            } else if (letter == '\n') {
                isTrans = NO;
                if (stringSign.length > 0) {
                } else {
                    if (isContent) {
                        for (NSInteger i=0; i<indent; i++) {
                            [reIndex appendString:@" "];
                        }
                    }
                }
            } else {
                isTrans = NO;
                if (stringSign.length > 0) {
                    stringSign = [stringSign stringByAppendingString:[NSString stringWithCharacters:&letter length:1]];
                }
            }
        }
        index++;
    }
    return reIndex;
}

@end
