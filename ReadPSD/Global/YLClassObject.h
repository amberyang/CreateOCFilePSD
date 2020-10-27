//
//  YLClassObject.h
//  ReadPSD
//
//  Created by amber on 2020/5/19.
//  Copyright © 2020 amber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLPascalString.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLClassObject : NSObject

@property (nonatomic, strong) YLPascalString *name;
@property (nonatomic, assign) NSInteger idLength;
@property (nonatomic, strong) NSString *idString;

@end

NS_ASSUME_NONNULL_END
