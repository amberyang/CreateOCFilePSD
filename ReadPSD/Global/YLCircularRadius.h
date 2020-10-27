//
//  YLCircularRadius.h
//  ReadPSD
//
//  Created by amber on 2019/12/19.
//  Copyright © 2019 amber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLCircularRadius : NSObject

@property (nonatomic, strong) NSMutableArray *alphaPoints;
@property (nonatomic, assign) double topright;
@property (nonatomic, assign) double topleft;
@property (nonatomic, assign) double bottomleft;
@property (nonatomic, assign) double bottomright;
@property (nonatomic, assign) double top;
@property (nonatomic, assign) double left;
@property (nonatomic, assign) double btom;
@property (nonatomic, assign) double rght;
@property (nonatomic, assign) NSInteger shapeType;
@property (nonatomic, assign) BOOL showImage;

+ (YLCircularRadius *)createCircularRadiusWithArray:(NSArray *)array;

- (NSInteger)cornerRadius;
- (BOOL)showShape;
- (BOOL)adjustFrame;

@end

NS_ASSUME_NONNULL_END
