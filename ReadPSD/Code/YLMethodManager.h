//
//  YLMethodManager.h
//  ReadPSD
//
//  Created by amber on 2020/6/5.
//  Copyright © 2020 amber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLPSDLayerRecordInfo.h"

@interface YLMethodManager : NSObject

+ (instancetype)shareInstance;

- (void)insertPath:(NSString *)path forClass:(NSString *)className;
- (BOOL)insertImage:(UIImage *)image imageName:(NSString *)imageName
             record:(YLPSDLayerRecordInfo *)record;


- (BOOL)insertProperty:(YLPSDLayerRecordInfo *)record viewClass:(NSString *)viewClass
            superClass:(NSString *)superClass value:(NSString *)value
                layout:(NSString *)layout initial:(NSString *)initial
         calculateSize:(NSString *)calculateSize;
- (BOOL)updateProperty:(YLPSDLayerRecordInfo *)record layout:(NSString *)layout;

- (BOOL)insertGlobalMethod:(NSString *)methodName content:(NSString *)methodContent
                 viewClass:(NSString *)viewClass superClass:(NSString *)superClass
                    record:(YLPSDLayerRecordInfo *)record;

+ (NSString *)filePath:(NSString *)filePath fileName:(NSString *)fileName;

- (void)writeCodeWithRecord:(NSArray<YLPSDLayerRecordInfo *> *)record;

@end
