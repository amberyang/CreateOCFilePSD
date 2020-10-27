//
//  YLCircularRadius.m
//  ReadPSD
//
//  Created by amber on 2019/12/19.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLCircularRadius.h"
#import "YLEffect.h"

@interface YLCircularRadius()

@property (nonatomic, assign) BOOL isShape;
@property (nonatomic, assign) BOOL hasFrame;

@end

@implementation YLCircularRadius

+ (YLCircularRadius *)createCircularRadiusWithArray:(NSArray *)array {
    YLCircularRadius *circular = [YLCircularRadius new];
    BOOL isShapeInvalidated = NO;
    for (NSDictionary *dic in array) {
        if ([dic objectForKey:@"keydescriptorlist"]) {
            NSArray *keydescriptorlist = [[dic objectForKey:@"keydescriptorlist"] objectForKey:@"vlls"];
            if (keydescriptorlist.count > 1) {
                circular.showImage = YES;
                break;
            }
            for (NSDictionary *kdObj in keydescriptorlist) {
                NSArray *kdObjlist = [[kdObj objectForKey:@"objc"] objectForKey:@"null"];
                if (!kdObjlist) {
                    kdObjlist = [[kdObj objectForKey:@"objc"] allValues][0];
                }
                BOOL hasShapeDesc = NO;
                for (NSDictionary *kdlObj in kdObjlist) {
                    if ([kdlObj objectForKey:@"keyoriginrrectradii"]) {
                        NSArray *radiis = [[[kdlObj objectForKey:@"keyoriginrrectradii"] objectForKey:@"objc"] objectForKey:@"radii"];
                        for (NSDictionary *radii in radiis) {
                            if ([radii objectForKey:@"topright"]) {
                                circular.topright = round([[[radii objectForKey:@"topright"] objectForKey:@"untf"] doubleValue]);
                            } else if ([radii objectForKey:@"topleft"]) {
                                circular.topleft = round([[[radii objectForKey:@"topleft"] objectForKey:@"untf"] doubleValue]);
                            } else if ([radii objectForKey:@"bottomleft"]) {
                                circular.bottomleft = round([[[radii objectForKey:@"bottomleft"] objectForKey:@"untf"] doubleValue]);
                            } else if ([radii objectForKey:@"bottomright"]) {
                                circular.bottomright = round([[[radii objectForKey:@"bottomright"] objectForKey:@"untf"] doubleValue]);
                            }
                        }
                    } else if ([kdlObj objectForKey:@"keyshapeinvalidated"]) {
                        isShapeInvalidated = [[[kdlObj objectForKey:@"keyshapeinvalidated"] objectForKey:@"bool"] boolValue];
                        if (circular.isShape) {
                            circular.isShape = NO;
                        }
                    } else if ([kdlObj objectForKey:@"keyoriginshapebbox"]) {
                        NSArray *objc = [[[kdlObj objectForKey:@"keyoriginshapebbox"] objectForKey:@"objc"] objectForKey:@"unitrect"];
                        if (objc) {
                            circular.hasFrame = YES;
                        }
                        for (NSDictionary *uvqv in objc) {
                            if ([uvqv objectForKey:@"top"]) {
                                circular.top = round([[[uvqv objectForKey:@"top"] objectForKey:@"untf"] doubleValue]);
                                
                            } else if ([uvqv objectForKey:@"left"]) {
                                circular.left = round([[[uvqv objectForKey:@"left"] objectForKey:@"untf"] doubleValue]);
                                
                            } else if ([uvqv objectForKey:@"btom"]) {
                                circular.btom = round([[[uvqv objectForKey:@"btom"] objectForKey:@"untf"] doubleValue]);
                                
                            } else if ([uvqv objectForKey:@"rght"]) {
                                circular.rght = round([[[uvqv objectForKey:@"rght"] objectForKey:@"untf"] doubleValue]);
                            }
                        }
                    } else if ([kdlObj objectForKey:@"keyorigintype"]) {
                        hasShapeDesc = YES;
                        //                               types = {1: Rectangle, 2: RoundedRectangle, 4: Line, 5: Ellipse}
                        circular.shapeType = [[[kdlObj objectForKey:@"keyorigintype"]  objectForKey:@"long"] longValue];
                        if (circular.shapeType == 1 || circular.shapeType == 2) {
                            circular.isShape = YES;
                        }
                        else if (isShapeInvalidated) {
                            circular.isShape = NO;
                        }
                    }
                }
                if (!hasShapeDesc) {
                    circular.isShape = YES;
                }
                break;
            }
        }
    }

    return circular;
}

- (BOOL)showShape {
    if (_isShape) {
        return _isShape;
    }
    if (_topright == _topleft && _bottomleft == _bottomright && _topright == _bottomleft) {
        return NO;
    }
    return NO;
}

- (BOOL)adjustFrame {
    return _hasFrame && ![self showShape];
}

- (NSInteger)cornerRadius {
    if ([self showShape]) {
        if (_topright == _topleft && _bottomleft == _bottomright && _topright == _bottomleft) {
            return _topright;
        }
    }
    if (_alphaPoints.count%2 == 0 && _alphaPoints.count > 8) {
        NSInteger width = 0;
        NSInteger height = 0;
        NSInteger widthCircus = 0;
        NSInteger heightCircus = 0;
        for (NSInteger i=0; i<_alphaPoints.count; i+=2) {
            CGPoint point1 = [[_alphaPoints objectAtIndex:i] CGPointValue];
            CGPoint point2 = [[_alphaPoints objectAtIndex:i+1] CGPointValue];
            if (point1.y == point2.y) {
                height = MAX(point2.y, height);
                width = MAX(width, point2.x);
                if (i < 4) {
                    widthCircus = MAX((width - point2.x), MAX(widthCircus, point1.x));
                    heightCircus = MAX(heightCircus, (height - point2.y));
                } else if (i > _alphaPoints.count - 5) {
                    widthCircus = MAX((width - point2.x), MAX(widthCircus, point1.x));
                    heightCircus = MAX(heightCircus, (point2.y - height));
                }
            }
        }
        return MAX(widthCircus, heightCircus);
    }
    return 0;
}

- (NSMutableArray *)alphaPoints {
    if (!_alphaPoints) {
        _alphaPoints = [NSMutableArray array];
    }
    return _alphaPoints;
}


@end
