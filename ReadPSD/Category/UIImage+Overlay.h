//
//  UIImage+Overlay.h
//  ReadPSD
//
//  Created by amber on 2019/12/25.
//  Copyright © 2019 amber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Overlay)

- (UIImage *)imageWithOverlayColor:(UIColor *)tintColor;

- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

@end

NS_ASSUME_NONNULL_END
