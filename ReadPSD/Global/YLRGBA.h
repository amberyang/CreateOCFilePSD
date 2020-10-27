//
//  YLRGBA.h
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLRGBA : NSObject<NSCopying>

@property (nonatomic, assign) unsigned int red;
@property (nonatomic, assign) unsigned int green;
@property (nonatomic, assign) unsigned int blue;
@property (nonatomic, assign) unsigned int alpha;
@property (nonatomic, assign) unsigned int mask;
@property (nonatomic, assign) BOOL enab;


+ (YLRGBA *)createRGBAColor:(NSArray *)array;

+ (YLRGBA *)createRGBAWithArray:(NSArray *)array;

+ (UIColor *)colorWithRGBA:(YLRGBA *)rgba;

- (BOOL)isEqualWithoutAlpha:(YLRGBA *)object;

+ (UIColor *)colorWithRGBA:(YLRGBA *)rgba overlay:(YLRGBA *)overlay;

+ (YLRGBA *)rgbaColorFromUIColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
