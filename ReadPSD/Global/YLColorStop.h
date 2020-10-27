//
//  YLColorStop.h
//  ReadPSD
//
//  Created by amber on 2019/12/19.
//  Copyright © 2019 amber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLColorStop : NSObject

//'Lctn'    Integer    Location    0 to 4096 (0% to 100%).
@property (nonatomic, assign) unsigned int *lctn;
//'Mdpn'    Integer    Midpoint    0% to 100%.
@property (nonatomic, assign) unsigned int mdpn;
//'Type'    Enumerated
//Color stop type:        Type:
//'Clry', 'UsrS'          User stop
//'Clry', 'BckC'          Background color
//'Clry', 'FrgC'          Foreground color
@property (nonatomic, assign) unsigned int type;
//'Clr '    Object
//Color object:           Key present only if color stop type is user stop:
//Book color object       Book color object format
//CMYK color object       CMYK color object format
//Grayscale object        Grayscale object format
//HSB color object        HSB color object format
//Lab color object        Lab color object format
//RGB color object        RGB color object format
@property (nonatomic, strong) NSObject *clr;

@end

NS_ASSUME_NONNULL_END
