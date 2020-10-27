//
//  YLImageProcess.h
//  ReadPSD
//
//  Created by amber on 2019/12/4.
//  Copyright © 2019 amber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLBGRGBA.h"
#import "YLPSDLayerRecordInfo.h"

@interface YLImageProcess : NSObject

UIImage *drawImageWithRGB(NSArray *array, NSInteger width, NSInteger height, YLBGRGBA **bgRGBA);

UIImage *drawImageWithRecord(YLPSDLayerRecordInfo *record, NSArray *array, NSInteger width, NSInteger height, YLBGRGBA **bgRGBA);

@end
