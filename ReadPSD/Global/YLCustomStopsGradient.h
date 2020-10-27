//
//  YLCustomStopsGradient.h
//  ReadPSD
//
//  Created by amber on 2019/12/19.
//  Copyright © 2019 amber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLColorStop.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLCustomStopsGradient : NSObject

//'Nm  '    String    Gradient name    Unicode string.
@property (nonatomic, copy) NSString *nm;
//Enumerated    Gradient form: custom stops (= 'GrdF', 'CstS')    Solid gradient.
@property (nonatomic, assign) unsigned int grdf;
//'Intr'    Double    Interpolation    0 to 4096 (Smoothness: 0% to 100%).
@property (nonatomic, assign) double intr;
//'Clrs'    List    List of color stops    Each in Color stop object format..
@property (nonatomic, strong) NSArray<YLColorStop *> *clrs;
//'Trns'    List    List of transparency stops    Each in Transparency stop object format.
@property (nonatomic, strong) NSArray *trns;

@end

NS_ASSUME_NONNULL_END
