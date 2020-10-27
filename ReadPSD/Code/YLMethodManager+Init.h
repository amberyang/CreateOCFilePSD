//
//  YLMethodManager+Init.h
//  ReadPSD
//
//  Created by amber on 2020/6/12.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLMethodManager.h"

@interface YLMethodManager (Init)

+ (NSString *)getRemarkCode:(NSString *)className suffix:(NSString *)subfix;
+ (NSString *)getImportCode:(NSString *)className;

@end
