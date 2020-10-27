//
//  YLEffectStroke.h
//  ReadPSD
//
//  Created by amber on 2019/12/24.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLInsideShadow.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLEffectStroke : YLInsideShadow

@property (nonatomic, assign) double sz;

@property (nonatomic, copy) NSString *type;

/*
 Style:
 'FStl', 'OutF'
 'FStl', 'InsF'
 'FStl', 'CtrF'
 */
@property (nonatomic, copy) NSString *styl;

@property (nonatomic, assign) BOOL overprint;


+ (YLEffectStroke *)createStokeWithArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
