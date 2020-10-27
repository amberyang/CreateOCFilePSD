//
//  YLImageInfo.h
//  ReadPSD
//
//  Created by amber on 2019/11/28.
//  Copyright © 2019 amber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLImageInfo : NSObject

@property (nonatomic, strong) NSMutableArray *layers;

@property (nonatomic, assign) CGSize size;

@end

NS_ASSUME_NONNULL_END
