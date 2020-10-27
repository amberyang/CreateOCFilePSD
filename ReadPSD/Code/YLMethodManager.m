//
//  YLMethodManager.m
//  ReadPSD
//
//  Created by amber on 2020/6/5.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLMethodManager.h"
#import "YLMethodManager+Init.h"
#import "YLMethodManager+ReIndex.h"
#import "YLMethodManager+Layout.h"
#import "YLClassT.h"
#import "YLCodeBuilder.h"
#import "YLPropertyT.h"

@interface YLMethodManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *classPathDic;
@property (nonatomic, strong) NSMutableDictionary<NSString *, YLClassT *> *globalObj;

@end

@implementation YLMethodManager

+ (instancetype)shareInstance {
    static YLMethodManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YLMethodManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *dirPath = [[self class] filePath:@"" fileName:@""];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
        for (NSString *fileName in files) {
            BOOL flag = YES;
            NSString *fullPath = [dirPath stringByAppendingPathComponent:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&flag]) {
                [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
            }
        }
    }
    return self;
}

- (void)insertPath:(NSString *)path forClass:(NSString *)className {
    if ([self.classPathDic objectForKey:className]) {
        NSLog(@"path is exist , old: %@ -- new : %@", [self.classPathDic objectForKey:className],path);
    }
    [self.classPathDic setObject:path forKey:className];
}

- (void)writeCodeWithRecord:(NSArray<YLPSDLayerRecordInfo *> *)record {
    [self writeGlobalFile];
    for (YLPSDLayerRecordInfo *rec in record) {
        [self writeRecordCode:rec];
    }
}

- (void)writeGlobalFile {
    for (YLClassT *obj in self.globalObj) {
        NSString *name = [YLCodeBuilder replaceSpecialWord:obj.className];
        NSString *path = [_classPathDic objectForKey:name];
        if (path) {
            NSString *dirPath = [[self class] filePath:path fileName:@""];
            NSString *filePath = [[self class] filePath:path fileName:obj.className];
            NSLog(@"direction path is %@",dirPath);
            if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *header = [filePath stringByAppendingString:@".h"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:header]) {
                BOOL isSucceed = [[NSFileManager defaultManager] createFileAtPath:header contents:nil attributes:nil];
                if (!isSucceed) {
                    NSLog(@"%@ file create failed",header);
                }
                NSString *headerContent = [[self class] getRemarkCode:obj.className suffix:@"h"];
                headerContent = [headerContent stringByAppendingString:@"#import <UIKit/UIKit.h>\n"];
                headerContent = [headerContent stringByAppendingFormat:@"\n\n@interface %@ : %@\n\n", obj.className, obj.superClass];
                headerContent = [headerContent stringByAppendingString:@"@end"];
                [headerContent writeToFile:header atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            NSString *implement = [filePath stringByAppendingString:@".m"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:implement]) {
                BOOL isSucceed = [[NSFileManager defaultManager] createFileAtPath:implement contents:nil attributes:nil];
                if (!isSucceed) {
                    NSLog(@"%@ file create failed",implement);
                }
                NSString *impContent = [[self class] getRemarkCode:obj.className suffix:@"m"];
                NSString *hImport = [[self class] getImportCode:obj.className];
                NSString *interface = [NSString stringWithFormat:@"@interface %@()\n\n",obj.className];
                
                interface = [interface stringByAppendingString:@"@end"];
                impContent = [impContent stringByAppendingFormat:@"%@\n\n%@\n\n@implementation %@\n\n",hImport,interface,obj.className];
                
                for (NSString *key in obj.methods) {
                    NSString *method = [NSString stringWithFormat:@"%@ {\n%@}\n\n",key,[obj.methods objectForKey:key]];
                    [[NSString stringWithFormat:@"%@;",method] writeToFile:header atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    impContent = [impContent stringByAppendingString:method];
                }
                                
                impContent = [impContent stringByAppendingString:@"@end"];
                impContent = [[self class] reIndent:impContent];

                [impContent writeToFile:implement atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }
    }
}

- (void)writeRecordCode:(YLPSDLayerRecordInfo *)record {

    YLClassT *obj = record.classObj;
    NSString *name = [YLCodeBuilder replaceSpecialWord:record.name.text];
    NSString *path = [_classPathDic objectForKey:name];
    if (path) {
        NSString *dirPath = [[self class] filePath:path fileName:@""];
        NSString *filePath = [[self class] filePath:path fileName:obj.className];
        NSLog(@"direction path is %@",dirPath);
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *header = [filePath stringByAppendingString:@".h"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:header]) {
            BOOL isSucceed = [[NSFileManager defaultManager] createFileAtPath:header contents:nil attributes:nil];
            if (!isSucceed) {
                NSLog(@"%@ file create failed",header);
            }
            NSString *headerContent = [[self class] getRemarkCode:obj.className suffix:@"h"];
            headerContent = [headerContent stringByAppendingString:@"#import <UIKit/UIKit.h>\n"];
            headerContent = [headerContent stringByAppendingFormat:@"\n\n@interface %@ : %@\n\n", obj.className, obj.superClass];
            headerContent = [headerContent stringByAppendingString:@"@end"];
            [headerContent writeToFile:header atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSString *implement = [filePath stringByAppendingString:@".m"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:implement]) {
            BOOL isSucceed = [[NSFileManager defaultManager] createFileAtPath:implement contents:nil attributes:nil];
            if (!isSucceed) {
                NSLog(@"%@ file create failed",implement);
            }
            NSString *impContent = [[self class] getRemarkCode:obj.className suffix:@"m"];
            NSString *hImport = [[self class] getImportCode:obj.className];
            
            for (NSString *className in obj.importH) {
                hImport = [hImport stringByAppendingString:[[self class] getImportCode:className]];
            }
            
            NSString *interface = [NSString stringWithFormat:@"@interface %@()\n\n",obj.className];
            
            NSString *value = @"- (void)p_setUp {\n";
            NSString *layout = @"- (void)p_layout {\n";
            NSString *initial = @"#pragma mark ---- init\n\n";
            NSString *sizeFit = @"- (CGSize)sizeThatFits:(CGSize)size {\n CGFloat totalHeight = 0;\n";

            NSArray<YLPropertyT *> *properties = [[self class] adjustLayoutRelation:record];
            for (YLPropertyT *property in properties) {
                NSString *propertyStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;\n",property.propertyClass, property.name];
                interface = [interface stringByAppendingString:propertyStr];
                if (![property.propertyClass hasPrefix:@"UI"]) {
                    hImport = [hImport stringByAppendingString:[[self class] getImportCode:property.propertyClass]];
                }
                value = [value stringByAppendingString:@"//----------------\n"];
                value = [value stringByAppendingString:property.value];
                value = [value stringByAppendingString:@"\n"];
                
                layout = [layout stringByAppendingString:@"//----------------\n"];
                NSString *append = [property.layout componentsJoinedByString:@""];
                layout = [layout stringByAppendingString:append];
                layout = [layout stringByAppendingString:@"\n"];
                
                sizeFit = [sizeFit stringByAppendingString:@"//----------------\n"];
                if (property.calculateSize.length > 0) {
                    if (property.topMargin > 0) {
                        if ([property.calculateSize containsString:@"sizeThatFits:CGSizeMake"]) {
                            sizeFit = [sizeFit stringByAppendingString:property.calculateSize];
                            if (!property.isOnlyCalculate) {
                                sizeFit = [sizeFit stringByAppendingFormat:@"totalHeight += (%.1f + ceil(%@_size.height));\n",property.topMargin,property.name];
                            }
                        } else {
                            if (!property.isOnlyCalculate) {
                                sizeFit = [sizeFit stringByAppendingFormat:@"totalHeight += (%.1f + %@);\n",property.topMargin,property.calculateSize];
                            }
                        }
                    } else {
                        if ([property.calculateSize containsString:@"sizeThatFits:CGSizeMake"]) {
                            sizeFit = [sizeFit stringByAppendingString:property.calculateSize];
                            if (!property.isOnlyCalculate) {
                                sizeFit = [sizeFit stringByAppendingFormat:@"totalHeight += ceil(%@_size.height);\n",property.name];
                            }
                        } else {
                            if (!property.isOnlyCalculate) {
                                sizeFit = [sizeFit stringByAppendingFormat:@"totalHeight += %@;\n",property.calculateSize];
                            }
                        }
                    }
                } else if (property.topMargin > 0) {
                    sizeFit = [sizeFit stringByAppendingFormat:@"totalHeight += %.1f;",property.topMargin];
                }
                sizeFit = [sizeFit stringByAppendingString:@"\n"];
                
                NSString *method = [NSString stringWithFormat:@"- (%@ *)%@ {\n%@}\n\n",property.propertyClass, property.name, property.initial];
                initial = [initial stringByAppendingString:method];
            }
            
            interface = [interface stringByAppendingString:@"@end"];
            impContent = [impContent stringByAppendingFormat:@"%@\n\n%@\n\n@implementation %@\n\n",hImport,interface,obj.className];
            impContent = [impContent stringByAppendingString:@"- (instancetype)initWithFrame:(CGRect)frame {\nself = [super initWithFrame:frame];\nif(self) {\n[self p_setUp];\n}\nreturn self;\n}\n\n"];
            impContent = [impContent stringByAppendingString:@"- (void)layoutSubviews {\n[super layoutSubviews];\n[self p_layout];\n}\n\n"];
            
            value = [value stringByAppendingString:@"[self setNeedsLayout];\n]}\n\n"];
            impContent = [impContent stringByAppendingString:value];
            sizeFit = [sizeFit stringByAppendingString:@"\nreturn CGSizeMake(size.width, totalHeight);\n}\n\n"];
            impContent = [impContent stringByAppendingString:sizeFit];
            layout = [layout stringByAppendingString:@"}\n\n"];
            impContent = [impContent stringByAppendingString:layout];
            
            for (NSString *key in obj.methods) {
                NSString *method = [NSString stringWithFormat:@"%@ {\n%@}\n\n",key,[obj.methods objectForKey:key]];
                [[NSString stringWithFormat:@"%@;",method] writeToFile:header atomically:YES encoding:NSUTF8StringEncoding error:nil];
                impContent = [impContent stringByAppendingString:method];
            }
            
            impContent = [impContent stringByAppendingString:initial];
            
            impContent = [impContent stringByAppendingString:@"@end"];
            impContent = [[self class] reIndent:impContent];

            [impContent writeToFile:implement atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        
        NSDictionary *imageDic = record.imageDic;
        for (NSString *imageName in imageDic) {
            UIImage *image = [imageDic objectForKey:imageName];
            NSString *imagePath = [[self class] filePath:path fileName:imageName];
            [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
        }
    }
    
    if (record.records) {
        for (YLPSDLayerRecordInfo *rec in record.records) {
            [self writeRecordCode:rec];
        }
    }
}

- (BOOL)insertProperty:(YLPSDLayerRecordInfo *)record viewClass:(NSString *)viewClass
            superClass:(NSString *)superClass value:(NSString *)value
                layout:(NSString *)layout initial:(NSString *)initial
         calculateSize:(NSString *)calculateSize {
    NSString *viewName = [YLCodeBuilder replaceSpecialWord:record.name.text];
    //添加类
    YLClassT *obj = [YLClassT new];
    if (record.classObj) {
        obj = record.classObj;
    }
    obj.superClass = superClass?:@"UIView";
    obj.className = viewClass?:superClass;
    if (record.parentRecord) {
        YLPropertyT *property = [YLPropertyT new];
        property.name = viewName;
        property.propertyClass = viewClass?:superClass;
        property.value = value;
        property.initial = initial;
        property.layout = [NSArray arrayWithObject:layout];
        property.calculateSize = calculateSize;
        YLClassT *parentObj = record.parentRecord.classObj;
        [parentObj insertProperty:property];
    }
    record.classObj = obj;
    return YES;
}

- (BOOL)updateProperty:(YLPSDLayerRecordInfo *)record layout:(NSString *)layout {
    NSString *className = [YLCodeBuilder replaceSpecialWord:record.parentRecord.name.text];
    NSString *viewName = [YLCodeBuilder replaceSpecialWord:record.name.text];
    NSString *viewClass = viewName.capitalizedString;
    if ([viewName stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0
        || [className stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0
        || [viewClass stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        return NO;
    }
    //添加类
    if (record.parentRecord) {
        YLClassT *parentObj = record.parentRecord.classObj;
        YLPropertyT *property = [parentObj getPropertyWithName:viewName];
        NSArray<NSString *> *layouts = [[self class] removeDuplicates:layout array:property.layout];
        property.layout = layouts;
    }
    return YES;
}

- (BOOL)insertImage:(UIImage *)image imageName:(NSString *)imageName record:(YLPSDLayerRecordInfo *)record {
    if (!image
        || [imageName stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        return NO;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (record.parentRecord.imageDic.count > 0) {
        [dic addEntriesFromDictionary:record.parentRecord.imageDic];
    }
    [dic setObject:image forKey:imageName];
    record.parentRecord.imageDic = dic;
    return YES;
}

- (BOOL)insertGlobalMethod:(NSString *)methodName content:(NSString *)methodContent
                 viewClass:(NSString *)viewClass superClass:(NSString *)superClass
                    record:(YLPSDLayerRecordInfo *)record {
    if (!viewClass) {
        return NO;
    }
    YLClassT *obj = [self.globalObj objectForKey:viewClass]?:[YLClassT new];
    obj.superClass = superClass?:@"NSObject";
    obj.className = viewClass;
    if ([obj.methods objectForKey:methodName]) {
        return YES;
    }
    NSMutableDictionary *methods = [[NSMutableDictionary alloc] init];
    if (obj.methods.count > 0) {
        [methods addEntriesFromDictionary:obj.methods];
    }
    [methods setObject:methodContent forKey:methodName];
    obj.methods = methods;
    [self.globalObj setObject:obj forKey:methodName];
    YLClassT *usedObj = record.classObj;
    if (!usedObj) {
        usedObj = [YLClassT new];
    }
    [usedObj insertImportFile:obj.className];
    return YES;
}

+ (NSString *)filePath:(NSString *)filePath fileName:(NSString *)fileName {
    NSString *component = [NSString stringWithFormat:@"%@%@%@",filePath,filePath.length>0?(fileName.length>0?@"/":@""):@"",fileName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *realPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:component];
    return realPath;
}

- (NSMutableDictionary<NSString *, NSString *> *)classPathDic {
    if (!_classPathDic) {
        _classPathDic = [[NSMutableDictionary alloc] init];
    }
    return _classPathDic;
}

- (NSMutableDictionary<NSString *, YLClassT *> *)globalObj {
    if (!_globalObj) {
        _globalObj = [NSMutableDictionary dictionary];
    }
    return _globalObj;
}

@end
