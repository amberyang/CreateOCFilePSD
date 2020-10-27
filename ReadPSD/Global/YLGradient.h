//
//  YLGradient.h
//  ReadPSD
//
//  Created by amber on 2019/12/19.
//  Copyright © 2019 amber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLRGBA.h"
#import "YLCustomStopsGradient.h"
#import "YLRGBAGradient.h"

@interface YLGradient : NSObject


//'enab'    Boolean    Enabled    Apply Gradient Overlay effect.
@property (nonatomic, assign) BOOL enab;
//'Md  '    Enumerated    Blend mode    Among Blend modes
@property (nonatomic, assign) unsigned int md;
//'Opct'    Unit double    Opacity (in '#Prc' units)    0% to 100%.
@property (nonatomic, assign) double opct;
//'Grad'    Object    Custom stops gradient object or Color noise gradient object
// Custom stops gradient object format or Color noise gradient object format.
@property (nonatomic, strong) YLCustomStopsGradient *grad;
//'Angl'    Unit double    Angle (in '#Ang' units)    -180° to 180°.
@property (nonatomic, assign) float angl;
//'Type'    Enumerated
// Type:            Style:
// 'GrdT', 'Lnr '      Linear
// 'GrdT', 'Rdl '      Radial
// 'GrdT', 'Angl'      Angle
// 'GrdT', 'Rflc'      Reflected
// 'GrdT', 'Dmnd'      Diamond
@property (nonatomic, copy) NSString *type;
// 'Rvrs'    Boolean    Reverse    Reverse direction of gradient.
@property (nonatomic, assign) BOOL rvrs;
// 'Algn'    Boolean    Align    Align with Layer.
@property (nonatomic, assign) BOOL algn;
// 'Scl '    Unit double    Scale (in '#Prc' units)    10% to 150%.
@property (nonatomic, assign) double scl;
// 'Ofst'    Object    Offset (drag to position with mouse down)    Offset point object format.
@property (nonatomic, strong) NSObject *ofst;
// 'Dthr'    Boolean    Dither    Only from CS6.
@property (nonatomic, assign) BOOL dthr;

@property (nonatomic, strong) NSArray<YLRGBAGradient *> *gradients;

+ (YLGradient *)createGradientWithArray:(NSArray *)array;

@end
