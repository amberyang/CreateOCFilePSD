//
//  YLStroke.h
//  ReadPSD
//
//  Created by amber on 2020/6/9.
//  Copyright © 2020 amber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLRGBA.h"

@interface YLStroke : NSObject

@property (nonatomic, assign) BOOL strokeenabled;
@property (nonatomic, assign) BOOL fillenabled;
@property (nonatomic, assign) double strokestylelinewidth;
@property (nonatomic, assign) double strokestylelinedashoffset;
@property (nonatomic, assign) double strokestylemiterlimit;
@property (nonatomic, copy) NSString *strokestylelinecaptype;
@property (nonatomic, copy) NSString *strokestylelinejointype;
@property (nonatomic, copy) NSString *strokestylelinealignment;
@property (nonatomic, assign) double strokestyleopacity;
@property (nonatomic, copy) NSString *strokestyleblendmode;
@property (nonatomic, strong) YLRGBA *rgba;

+ (YLStroke *)createStokeWithArray:(NSArray *)array;

@end
