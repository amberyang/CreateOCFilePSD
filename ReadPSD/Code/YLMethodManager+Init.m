//
//  YLMethodManager+Init.m
//  ReadPSD
//
//  Created by amber on 2020/6/12.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLMethodManager+Init.h"

@implementation YLMethodManager (Init)

+ (NSString *)getRemarkCode:(NSString *)className suffix:(NSString *)suffix {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY/MM/dd";
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSMutableString *content = [[NSMutableString alloc] initWithFormat:@"//\n"
                                "//  %@%@\n"
                                "//  %@\n"
                                "//\n"
                                "//  Created by %@ on %@.\n"
                                "//  Copyright © %@年 %@. All rights reserved.\n"
                                "//\n\n\n",className,suffix,@"workspace",NSUserName(),dateString,[dateString substringToIndex:3],NSUserName()];
    return content;
}

+ (NSString *)getImportCode:(NSString *)className {
    return [NSString stringWithFormat:@"#import \"%@.h\"\n",className];
}

//- (NSString *)getInterfaceCode {
//    if (self.properties.count == 0) {
//        return @"";
//    }
//    NSString *code = [NSString stringWithFormat:@"@interface %@\n\n",self.className];
//    for (YLCreateObject *item in self.properties) {
//        code = [code stringByAppendingFormat:@"%@\n",[item propertyCode]];
//    }
//    code = [code stringByAppendingString:@"@end\n\n"];
//    return code;
//}

//- (NSString *)getImplementationCode {
//    NSString *code = [NSString stringWithFormat:@"@implementation %@\n",self.className];
//    NSMutableDictionary *sortDic = [[NSMutableDictionary alloc] init];
//    for (YLCreateObject *item in self.properties) {
//        for (YLMethodObject *method in item.methods) {
//            NSMutableArray *array = [sortDic objectForKey:@(method.type).stringValue];
//            if (!array) {
//                array = [[NSMutableArray alloc] init];
//            }
//            [array addObject:method];
//            [sortDic setObject:array forKey:@(method.type).stringValue];
//        }
//    }
//
//    NSMutableDictionary *dic = [self methods];
//    for (NSString *key in dic) {
//        NSMutableArray *array = [dic objectForKey:key];
//        if (!array) {
//            array = [[NSMutableArray alloc] init];
//        }
//        NSArray *current = [sortDic objectForKey:key];
//        if (current.count > 0) {
//            [array addObjectsFromArray:current];
//        }
//        [sortDic setObject:array forKey:key];
//    }
//
//    code = [code stringByAppendingString:[self getFormatMethodsCode:sortDic]];
//    code = [code stringByAppendingString:@"@end\n\n"];
//    return code;
//}

@end
