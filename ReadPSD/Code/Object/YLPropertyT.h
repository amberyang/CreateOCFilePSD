//
//  YLPropertyT.h
//  ReadPSD
//
//  Created by amber on 2020/7/1.
//  Copyright © 2020 amber. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YLClassT;

@interface YLPropertyT : NSObject<NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *propertyClass;

@property (nonatomic, copy) NSString *value;
@property (nonatomic, strong) NSArray *layout;
@property (nonatomic, copy) NSString *initial;
@property (nonatomic, copy) NSString *calculateSize;
@property (nonatomic, assign) BOOL isOnlyCalculate;
@property (nonatomic, assign) float topMargin;

@end
