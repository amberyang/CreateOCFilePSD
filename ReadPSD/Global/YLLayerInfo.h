//
//  YLLayerInfo.h
//  ReadPSD
//
//  Created by amber on 2019/10/9.
//  Copyright © 2019 amber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLLayerInfo : NSObject

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) NSInteger layerType;

@property (nonatomic, assign) BOOL isHidden;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSMutableArray *layers;

@end
