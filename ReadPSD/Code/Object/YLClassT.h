//
//  YLClassT.h
//  ReadPSD
//
//  Created by amber on 2020/7/1.
//  Copyright © 2020 amber. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YLPropertyT;

@interface YLClassT : NSObject

@property (nonatomic, copy) NSString *className;

@property (nonatomic, copy) NSString *superClass;

@property (nonatomic, strong) NSArray<YLPropertyT *> *properties;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *methods;

@property (nonatomic, strong) NSArray<NSString *> *importH;

- (void)insertProperty:(YLPropertyT *)property;

- (YLPropertyT *)getPropertyWithName:(NSString *)name;

- (void)insertImportFile:(NSString *)importH;

@end
