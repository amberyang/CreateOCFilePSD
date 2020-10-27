//
//  YLInsideShadow.h
//  ReadPSD
//
//  Created by amber on 2019/12/23.
//  Copyright © 2019 amber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLRGBA.h"


@interface YLInsideShadow : NSObject

//'enab'    Boolean    Enabled    Apply Inner Shadow effect.
@property (nonatomic, assign) BOOL enab;

//'Opct'    Unit double    Opacity (in '#Prc' units)    0% to 100%.
@property (nonatomic, assign) double opct;

//'uglg'    Boolean    Use global angle    Use Global Light.
@property (nonatomic, assign) BOOL uglg;

//Unit double    Local lighting angle (in '#Ang' units)    Angle: -180° to 180°..
@property (nonatomic, assign) double lagl;

//'Dstn'    Unit double    Distance (in '#Pxl' units)    0 to 30000 pixels.
@property (nonatomic, assign) double dstn;

//'blur'    Unit double    Blur (in '#Pxl' units)    Size: 0 to 250 pixels.
@property (nonatomic, assign) double blur;

@property (nonatomic, strong) YLRGBA *rgba;

+ (YLInsideShadow *)createInsideShadowWithArray:(NSArray *)array;

@end
