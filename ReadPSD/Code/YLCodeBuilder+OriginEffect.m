//
//  YLCodeBuilder+OriginEffect.m
//  ReadPSD
//
//  Created by amber on 2020/6/9.
//  Copyright © 2020 amber. All rights reserved.
//

#import "YLCodeBuilder+OriginEffect.h"

@implementation YLCodeBuilder (OriginEffect)

+ (NSString *)addStoke:(YLPSDLayerRecordInfo *)record layer:(CALayer *)layer name:(NSString *)name {
    NSString *code = @"";
    if (layer) {
        if (record.bgColor.stoke) {
            YLStroke *stoke = record.bgColor.stoke;
            if (stoke.strokestylelinewidth > 0) {
                layer.borderColor = [YLRGBA colorWithRGBA:stoke.rgba].CGColor;
                layer.borderWidth = stoke.strokestylelinewidth;
                code = [NSString stringWithFormat:@"%@.borderColor = %@.CGColor;\n"
                        "%@.borderWidth = %.1f;\n",name,[self colorStringWithRGBA:stoke.rgba],name,stoke.strokestylelinewidth];
            }
        }
    }
    return @"";
}

+ (NSString *)setAlpha:(YLPSDLayerRecordInfo *)record layer:(CALayer *)layer name:(NSString *)name  {
    NSString *code = @"";
    if (record.opacity != 255) {
        code = [NSString stringWithFormat:@"[%@ setOpacity:%.1f];\n", name, record.opacity/255.0];
    }
    
    if (layer) {
        [layer setOpacity:(record.opacity/255.0)];
        
        YLPSDAdditionalLayerInfo *addtional = [record.adjustments objectForKey:@"iopa"];
        NSDictionary *dic = [addtional.result objectForKey:@"iopa"];
        
        if (dic.count > 0) {
            NSString *opacity = [dic objectForKey:@"mix_opacity"];
            if (opacity) {
                [layer setOpacity:((record.opacity/255.0)*([opacity integerValue]/255.0))];
                code = [NSString stringWithFormat:@"[%@ setOpacity:%.1f];\n", name, record.opacity/255.0];
            }
        }
    }
    return code;
}

@end
