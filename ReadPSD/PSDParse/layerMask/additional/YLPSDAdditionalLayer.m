//
//  YLPSDAdditionalLayer.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDAdditionalLayer.h"
#import "YLDataProcess.h"
#import "YLPSDDescriptor.h"
#import "YLPSDLayerRecordInfo.h"
#import "YLFileProcess.h"
#import "YLEffectLayerInfo.h"
#import "YLPSDEngineData.h"

@interface YLPSDAdditionalLayer()

@property (nonatomic, strong, readwrite) YLPSDAdditionalLayerInfo *adjustment;

@end

@implementation YLPSDAdditionalLayer

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index record:(YLPSDLayerRecordInfo *)record {
    self.startIndex = index;
        
    _adjustment = [YLPSDAdditionalLayerInfo new];
    _adjustment.startIndex = index;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    //Always 8BIM.
    unsigned char aliSignature[4] = {0};
    [fileData getBytes:&aliSignature range:NSMakeRange(index, sizeof(aliSignature))];
    NSData *data = [NSData dataWithBytes:aliSignature length:sizeof(aliSignature)];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"adjustment layer info signature is %@", string);
    _adjustment.signature = string;
    
    index += sizeof(aliSignature);
    
    //OSType key for which adjustment type to use: 'levl'=Levels
    //'curv'=Curves
    //'brit'=Brightness/contrast
    //'blnc'=Color balance 'hue '=Hue/saturation 'selc'=Selective color 'thrs'=Threshold 'nvrt'=Invert 'post'=Posterize
    unsigned char aliKey[4] = {0};
    [fileData getBytes:&aliKey range:NSMakeRange(index, sizeof(aliKey))];
    data = [NSData dataWithBytes:aliKey length:sizeof(aliKey)];
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"adjustment layer info key is %@", string);
    
    string = [string.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _adjustment.key = string;
    
    index += sizeof(aliKey);
    
    NSArray *array = @[@"lmsk", @"lr16", @"lr32", @"layr", @"mt16", @"mt32", @"mtrn", @"alph", @"fmsk", @"lnk2", @"feid", @"fxid", @"pxsd"];
    
    //Length of adjustment data, below.
    unsigned char aliLength[4] = {0};
    [fileData getBytes:&aliLength range:NSMakeRange(index, sizeof(aliLength))];
    unsigned int adLayerInfoLength = [YLDataProcess bytesToInt:aliLength length:sizeof(aliLength)];
    
#pragma mark ---- * maybe error
    adLayerInfoLength = (adLayerInfoLength + 3) & ~0x03;
    NSLog(@"adjustment data length is %d", adLayerInfoLength);
    _adjustment.length = adLayerInfoLength;
    
    index += sizeof(aliLength);
    NSInteger endIndex = index + adLayerInfoLength;
        
    if ([@"tysh" isEqualToString:string]) {
        
//                    const double f = 1.0;
//                    unsigned char b[sizeof(double)];
//                    memcpy(b, &f, sizeof(f));
//                    double newF = 0.0;
//                    memcpy(&newF, b, sizeof(double));
//
//                    const float ff = 1.0;
//                    unsigned char bb[sizeof(float)];
//                    memcpy(bb, &ff, sizeof(ff));
//                    float newFf = 0.0;
//                    memcpy(&newFf, bb, sizeof(float));
        
#pragma mark --- # Type Tool Info
        //Version ( =1 for Photoshop 6.0).
        unsigned char ttVer[2] = {0};
        [fileData getBytes:&ttVer range:NSMakeRange(index, sizeof(ttVer))];
        unsigned int ttVersion = [YLDataProcess bytesToInt:ttVer length:sizeof(ttVer)];

        NSLog(@"Type Tool Info version is %d", ttVersion);
        
        index += sizeof(ttVer);
        
        //XX
        unsigned char ttXX[8] = {0};
        [fileData getBytes:&ttXX range:NSMakeRange(index, sizeof(ttXX))];
        double ttTransXX = [YLDataProcess byteToDouble:ttXX];
        NSLog(@"Transform XX is %f", ttTransXX);
        
        index += sizeof(ttXX);
        
        //XY
        unsigned char ttXY[8] = {0};
        [fileData getBytes:&ttXY range:NSMakeRange(index, sizeof(ttXY))];
        double ttTransXY = [YLDataProcess byteToDouble:ttXY];
        NSLog(@"Transform XY is %f", ttTransXY);
        
        index += sizeof(ttXY);
        
        //YX
        unsigned char ttYX[8] = {0};
        [fileData getBytes:&ttYX range:NSMakeRange(index, sizeof(ttYX))];
        double ttTransYX = [YLDataProcess byteToDouble:ttYX];
        NSLog(@"Transform YX is %f", ttTransYX);
        
        index += sizeof(ttYX);
        
        //YY
        unsigned char ttYY[8] = {0};
        [fileData getBytes:&ttYY range:NSMakeRange(index, sizeof(ttYY))];
        double ttTransYY = [YLDataProcess byteToDouble:ttYY];
        NSLog(@"Transform YY is %f", ttTransYY);
        
        index += sizeof(ttYY);
        
        if (round(ttTransXX) == 0) {
            [dictionary setObject:@(asin(ttTransXY)) forKey:@"trans_angl"];
        } else if (round(ttTransYY) == 0) {
            [dictionary setObject:@(asin(ttTransYX)) forKey:@"trans_angl"];
        } else {
            if (round(ttTransXY) == 0 && ttTransXX == 1) {
                
            } else {
                [dictionary setObject:@(atan(ttTransXY/ttTransXX)) forKey:@"trans_angl"];
            }
        }
        
        //TX
        unsigned char ttTX[8] = {0};
        [fileData getBytes:&ttTX range:NSMakeRange(index, sizeof(ttTX))];
        double ttTransTX = [YLDataProcess byteToDouble:ttTX];
        NSLog(@"Transform TX is %f", ttTransTX);
        
        index += sizeof(ttTX);
        
        //TY
        unsigned char ttTY[8] = {0};
        [fileData getBytes:&ttTY range:NSMakeRange(index, sizeof(ttTY))];
        double ttTransTY = [YLDataProcess byteToDouble:ttTY];
        NSLog(@"Transform TY is %f", ttTransTY);
        
        index += sizeof(ttTY);
        
        //Text version ( = 50 for Photoshop 6.0)
        unsigned char textVer[2] = {0};
        [fileData getBytes:&textVer range:NSMakeRange(index, sizeof(textVer))];
        unsigned int textVersion = [YLDataProcess bytesToInt:textVer length:sizeof(textVer)];
        
        NSLog(@"Type Tool Info text version is %d", textVersion);
        
        index += sizeof(textVer);
        
        //Descriptor version ( = 16 for Photoshop 6.0)
        unsigned char desVer[4] = {0};
        [fileData getBytes:&desVer range:NSMakeRange(index, sizeof(desVer))];
        unsigned int descVersion = [YLDataProcess bytesToInt:desVer length:sizeof(desVer)];
        
        NSLog(@"Type Tool Info descriptor version is %d", descVersion);
        
        index += sizeof(desVer);
        
#pragma mark --- ## Descriptor structure Text data
        YLPSDDescriptor *textDescriptor = [YLPSDDescriptor new];
        [textDescriptor parse:fileData index:index];
        index = textDescriptor.endIndex;
        if (textDescriptor.result.count > 0) {
            [dictionary setObject:textDescriptor.result forKey:@"result"];
        }
        
        //Warp version ( = 1 for Photoshop 6.0)
        unsigned char warpVer[2] = {0};
        [fileData getBytes:&warpVer range:NSMakeRange(index, sizeof(warpVer))];
        unsigned int warpVersion = [YLDataProcess bytesToInt:warpVer length:sizeof(warpVer)];
        
        NSLog(@"Type Tool Info warp version is %d", warpVersion);
        
        index += sizeof(warpVer);
        
        //Descriptor version ( = 16 for Photoshop 6.0)
        unsigned char desWVer[4] = {0};
        [fileData getBytes:&desWVer range:NSMakeRange(index, sizeof(desWVer))];
        unsigned int descWVersion = [YLDataProcess bytesToInt:desWVer length:sizeof(desWVer)];
        
        NSLog(@"Type Tool Info descriptor version is %d", descWVersion);
        
        index += sizeof(desWVer);
        
        YLPSDDescriptor *warpDescriptor = [YLPSDDescriptor new];
        [warpDescriptor parse:fileData index:index];
        index = warpDescriptor.endIndex;
//        if (warpDescriptor.result.count > 0) {
//            [dictionary setObject:warpDescriptor.result forKey:@"warp_descriptor"];
//        }
       
        //The rectangle containing the contents of the layer.
        unsigned char ttTop[4] = {0};
        [fileData getBytes:&ttTop range:NSMakeRange(index, sizeof(ttTop))];
        int tyshTop = [YLDataProcess bytesToInt:ttTop length:sizeof(ttTop) sign:YES];
        NSLog(@"tysh top is %d", tyshTop);
        
        index += sizeof(ttTop);
        
        unsigned char ttLeft[4] = {0};
        [fileData getBytes:&ttLeft range:NSMakeRange(index, sizeof(ttLeft))];
        int tyshLeft = [YLDataProcess bytesToInt:ttLeft length:sizeof(ttLeft) sign:YES];
        NSLog(@"tysh left is %d", tyshLeft);
        
        index += sizeof(ttLeft);
        
        unsigned char ttBottom[4] = {0};
        [fileData getBytes:&ttBottom range:NSMakeRange(index, sizeof(ttBottom))];
        int tyshBottom = [YLDataProcess bytesToInt:ttBottom length:sizeof(ttBottom) sign:YES];
        NSLog(@"tysh bottom is %d", tyshBottom);
        
        index += sizeof(ttBottom);
        
        unsigned char ttRight[4] = {0};
        [fileData getBytes:&ttRight range:NSMakeRange(index, sizeof(ttRight))];
        int tyshRight = [YLDataProcess bytesToInt:ttRight length:sizeof(ttRight) sign:YES];
        NSLog(@"tysh right is %d", tyshRight);
        
        index += sizeof(ttRight);

    } else if ([@"luni" isEqualToString:string]) {
        
#pragma mark --- # Unicode Layer name
        //name from classid
        YLPascalString *ulName = [YLFileProcess getUnicodeStringFromFile:fileData index:&index];
        NSLog(@"Unicode layer name length is %d", ulName.length);
        NSLog(@"Unicode layer name is %@", ulName.text);
    } else if ([@"lnsr" isEqualToString:string]) {
        
        NSString *name = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
        NSLog(@"Layer name source name id is %@", name);
 
    } else if ([@"lyid" isEqualToString:string]) {
        unsigned char lyId[4] = {0};
        [fileData getBytes:&lyId range:NSMakeRange(index, sizeof(lyId))];
        unsigned int ly_id = [YLDataProcess bytesToInt:lyId length:sizeof(lyId)];
        
        NSLog(@"Layer ID is %d", ly_id);
        
        index += sizeof(lyId);
        [dictionary setObject:@(ly_id) forKey:@"layer_id"];
    } else if ([@"clbl" isEqualToString:string]) {
        //Blend clipped elements: boolean
        unsigned char clLen[1] = {0};
        [fileData getBytes:&clLen range:NSMakeRange(index, sizeof(clLen))];
        unsigned int clLength = [YLDataProcess bytesToInt:clLen length:sizeof(clLen)];
        
        NSLog(@"Blend clipping elements boolean is %d", clLength != 0);
        
        [dictionary setObject:@(clLength) forKey:@"blend_clip"];
                
        index += sizeof(clLen);
        //+ 3 padding
        unsigned char pad[3] = {0};
        [fileData getBytes:&pad range:NSMakeRange(index, sizeof(pad))];
        unsigned int padding = [YLDataProcess bytesToInt:pad length:sizeof(pad)];
        
        NSLog(@"Blend clipping elements padding is %d", padding);
        
        index += sizeof(pad);
    } else if ([@"knko" isEqualToString:string]) {
           //Knockout: boolean
           unsigned char clLen[1] = {0};
           [fileData getBytes:&clLen range:NSMakeRange(index, sizeof(clLen))];
           unsigned int clLength = [YLDataProcess bytesToInt:clLen length:sizeof(clLen)];
           
           NSLog(@"Knockout boolean is %d", clLength != 0);
           
           index += sizeof(clLen);
           //+ 3 padding
           unsigned char pad[3] = {0};
           [fileData getBytes:&pad range:NSMakeRange(index, sizeof(pad))];
           unsigned int padding = [YLDataProcess bytesToInt:pad length:sizeof(pad)];
           
           NSLog(@"Knockout padding is %d", padding);
           
           index += sizeof(pad);
       } else if ([@"infx" isEqualToString:string]) {
        //Blend interior elements: boolean
        unsigned char clLen[1] = {0};
        [fileData getBytes:&clLen range:NSMakeRange(index, sizeof(clLen))];
        unsigned int clLength = [YLDataProcess bytesToInt:clLen length:sizeof(clLen)];
        
        NSLog(@"Blend interior elements boolean is %d", clLength != 0);
        
        index += sizeof(clLen);
        //+ 3 padding
        unsigned char pad[3] = {0};
        [fileData getBytes:&pad range:NSMakeRange(index, sizeof(pad))];
        unsigned int padding = [YLDataProcess bytesToInt:pad length:sizeof(pad)];
        
        NSLog(@"Blend interior elements padding is %d", padding);
        
        index += sizeof(pad);
    } else if ([@"lsct" isEqualToString:string]) {
        //4 possible values, 0 = any other type of layer, 1 = open "folder", 2 = closed "folder", 3 = bounding section divider, hidden in the UI
        unsigned char lsType[4] = {0};
        [fileData getBytes:&lsType range:NSMakeRange(index, sizeof(lsType))];
        unsigned int lsctType = [YLDataProcess bytesToInt:lsType length:sizeof(lsType)];
        
        NSLog(@"Section divider setting type is %d", lsctType);
        
        index += sizeof(lsType);

//        _adjustment.layerType = lsctType;
        record.layerType = lsctType;
                            
        //Following is only present if length >= 12
        if (endIndex - index >= 8) {
            //Signature: '8BIM
            unsigned char lsSign[4] = {0};
            [fileData getBytes:&lsSign range:NSMakeRange(index, sizeof(lsSign))];
            data = [NSData dataWithBytes:lsSign length:sizeof(lsSign)];
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Section divider setting signature is %@", string);
            
            index += sizeof(lsSign);
            
            //Key. See blend mode keys in See Layer records.
            unsigned char lsKey[4] = {0};
            [fileData getBytes:&lsKey range:NSMakeRange(index, sizeof(lsKey))];
            data = [NSData dataWithBytes:lsKey length:sizeof(lsKey)];
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Section divider setting key is %@", string);
            
            index += sizeof(lsSign);
            //Following is only present if length >= 16
            if (endIndex - index >= 4) {
                //Sub type. 0 = normal, 1 = scene group, affects the animation timeline.
                unsigned char lsSubType[4] = {0};
                [fileData getBytes:&lsSubType range:NSMakeRange(index, sizeof(lsSubType))];
                unsigned int lsctSubType = [YLDataProcess bytesToInt:lsSubType length:sizeof(lsSubType)];
                
                NSLog(@"Section divider setting sub type is %d", lsctSubType);

                index += sizeof(lsSubType);
            }
        }
    } else if ([@"lsdk" isEqualToString:string]) {
        unsigned char lsType[4] = {0};
        [fileData getBytes:&lsType range:NSMakeRange(index, sizeof(lsType))];
        unsigned int lsctType = [YLDataProcess bytesToInt:lsType length:sizeof(lsType)];

        NSLog(@"Type Tool Info lsdk type is %d", lsctType);

        index += sizeof(lsType);

//        _adjustment.layerType = lsctType;
        record.layerType = lsctType;

    } else if ([@"lspf" isEqualToString:string]) {
        //Protection flags: bits 0 - 2 are used for Photoshop 6.0. Transparency, composite and position respectively.
        unsigned char lspf[4] = {0};
        [fileData getBytes:&lspf range:NSMakeRange(index, sizeof(lspf))];
        unsigned int flags = [YLDataProcess bytesToInt:lspf length:sizeof(lspf)];

        NSLog(@"Protected setting protection flag is %d", flags);

        index += sizeof(lspf);

    } else if ([@"lclr" isEqualToString:string]) {
       //4 * 2 Color. Only the first color setting is used for Photoshop 6.0; the rest are zeros

       unsigned char lclr[2] = {0};
       [fileData getBytes:&lclr range:NSMakeRange(index, sizeof(lclr))];
       unsigned int color = [YLDataProcess bytesToInt:lclr length:sizeof(lclr)];

       NSLog(@"Sheet color setting is %d", color);

       index += sizeof(lclr) +  3 * 2;

    } else if ([@"shmd" isEqualToString:string]) {
#pragma mark ----  # Metadata setting
        
        //Count of metadata items to follow
        unsigned char len[4] = {0};
        [fileData getBytes:&len range:NSMakeRange(index, sizeof(len))];
        unsigned int count = [YLDataProcess bytesToInt:len length:sizeof(len)];

        NSLog(@"Count of metadata items is %d", count);

        index += sizeof(len);
        
        for (unsigned int i=0; i<count; i++) {
            
            unsigned char sign[4] = {0};
            [fileData getBytes:&sign range:NSMakeRange(index, sizeof(sign))];
            data = [NSData dataWithBytes:sign length:sizeof(sign)];
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Metadata setting signature is %@", string);
            
            index += sizeof(sign);
            
            unsigned char key[4] = {0};
            [fileData getBytes:&key range:NSMakeRange(index, sizeof(key))];
            data = [NSData dataWithBytes:key length:sizeof(key)];
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Metadata setting key is %@", string);
            
            index += sizeof(key);
            
            unsigned char dup[1] = {0};
            [fileData getBytes:&dup range:NSMakeRange(index, sizeof(dup))];
            unsigned short int duplication = [YLDataProcess bytesToInt:dup length:sizeof(dup)];

            NSLog(@"Copy on sheet duplication is %d", duplication);

            index += sizeof(dup);
            
            unsigned char pad[3] = {0};
            [fileData getBytes:&pad range:NSMakeRange(index, sizeof(pad))];
            unsigned int padding = [YLDataProcess bytesToInt:pad length:sizeof(pad)];

            NSLog(@"Metadata setting Padding is %d", padding);

            index += sizeof(pad);
            
            unsigned char itemLen[4] = {0};
            [fileData getBytes:&itemLen range:NSMakeRange(index, sizeof(itemLen))];
            unsigned int itemLength = [YLDataProcess bytesToInt:itemLen length:sizeof(itemLen)];

            NSLog(@"Length of data to follow is %d", itemLength);

            index += sizeof(itemLen) + itemLength;
        }

    } else if ([@"fxrp" isEqualToString:string]) {
#pragma mark ----  Reference point
        //2 * 8 2 double values for the reference poin

        unsigned char fxrpX[8] = {0};
        [fileData getBytes:&fxrpX range:NSMakeRange(index, sizeof(fxrpX))];
        double xValue = [YLDataProcess byteToDouble:fxrpX];

        NSLog(@"Reference point X is %f", xValue);

        index += sizeof(fxrpX);
        
        unsigned char fxrpY[8] = {0};
        [fileData getBytes:&fxrpX range:NSMakeRange(index, sizeof(fxrpY))];
        double yValue = [YLDataProcess byteToDouble:fxrpY];

        NSLog(@"Reference point Y is %f", yValue);

        index += sizeof(fxrpY);

    } else if ([@"soco" isEqualToString:string]) {
    #pragma mark ----  Solid color sheet setting
        //Version ( = 16 for Photoshop 6.0)
        unsigned char version[4] = {0};
        [fileData getBytes:&version range:NSMakeRange(index, sizeof(version))];
        unsigned int sosoVer = [YLDataProcess bytesToInt:version length:sizeof(version)];

        NSLog(@"Solid color sheet setting version is %d", sosoVer);

        index += sizeof(version);
        
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        
        if (descriptor.result.count > 0) {
            [dictionary setObject:descriptor.result forKey:@"result"];
        }

    } else if ([@"lfx2" isEqualToString:string]) {
        
#pragma mark ----  Object-based effects layer info
        //Object effects version: 0
        unsigned char version[4] = {0};
        [fileData getBytes:&version range:NSMakeRange(index, sizeof(version))];
        unsigned int lfx2Ver = [YLDataProcess bytesToInt:version length:sizeof(version)];

        NSLog(@"Object effects version is %d", lfx2Ver);

        index += sizeof(version);
        
        //Descriptor version ( = 16 for Photoshop 6.0)
        unsigned char descVer[4] = {0};
        [fileData getBytes:&descVer range:NSMakeRange(index, sizeof(descVer))];
        unsigned int lfx2DescVer = [YLDataProcess bytesToInt:descVer length:sizeof(descVer)];

        NSLog(@"Descriptor version is %d", lfx2DescVer);

        index += sizeof(descVer);

        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        if (descriptor.result.count > 0) {
            [dictionary setObject:descriptor.result forKey:@"result"];
        }

    } else if ([@"lrfx" isEqualToString:string]) {
#pragma mark ----  Effects Layer
#pragma mark ----  # Effects Layer info
        unsigned char version[2] = {0};
        [fileData getBytes:&version range:NSMakeRange(index, sizeof(version))];
        unsigned int elVer = [YLDataProcess bytesToInt:version length:sizeof(version)];

        NSLog(@"Effects Layer info version is %d", elVer);

        index += sizeof(version);
        
        //Effects count: may be 6 (for the 6 effects in Photoshop 5 and 6) or 7 (for Photoshop 7.0)
        unsigned char count[2] = {0};
        [fileData getBytes:&count range:NSMakeRange(index, sizeof(count))];
        unsigned int elCount = [YLDataProcess bytesToInt:count length:sizeof(count)];

        NSLog(@"Effects count is %d", elCount);

        index += sizeof(count);
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];

        for (unsigned int i=0; i<elCount; i++) {
            
            unsigned char sign[4] = {0};
            [fileData getBytes:&sign range:NSMakeRange(index, sizeof(sign))];
            data = [NSData dataWithBytes:sign length:sizeof(sign)];
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Effects Layer info signature is %@", string);
            
            index += sizeof(sign);
            
            unsigned char key[4] = {0};
            [fileData getBytes:&key range:NSMakeRange(index, sizeof(key))];
            data = [NSData dataWithBytes:key length:sizeof(key)];
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Effects Layer info key is %@", string);
            
            index += sizeof(key);
            
            string = [string.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSMutableDictionary *effectDic = [[NSMutableDictionary alloc] init];

            if ([@"cmns" isEqualToString:string]) {
#pragma mark --- ## common state info
                unsigned int cmSize = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
                NSLog(@"common state info Size of next three items is %d", cmSize);

                unsigned int cmVersion = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
                NSLog(@"common state info version is %d", cmVersion);
                
                unsigned short int cmVis = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"common state info Visible is %d", cmVis != 0);
                
                unsigned short int cmUnused = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"common state info unused is %d", cmUnused);
                
            } else if ([@"dsdw" isEqualToString:string]) {
#pragma mark ------ ## Effects layer, drop shadow and inner shadow info
                //41 or 51 (depending on version)
                YLEffectLayerInfo *layerInfo = [self parseEffectsInfo:fileData index:&index prefix:@"drop shadow info"];
                
                unsigned char angle[4] = {0};
                [fileData getBytes:&angle range:NSMakeRange(index, sizeof(angle))];
                unsigned int dsAngle = [YLDataProcess bytesToInt:angle length:sizeof(angle)];

                NSLog(@"drop shadow info Angle in degrees is %d", dsAngle);

                index += sizeof(angle);
                
                unsigned char distance[4] = {0};
                [fileData getBytes:&distance range:NSMakeRange(index, sizeof(distance))];
                unsigned int dsdis = [YLDataProcess bytesToInt:distance length:sizeof(distance)];

                NSLog(@"drop shadow info Distance in pixels is %d", dsdis);

                index += sizeof(distance);
                
                //Color: 2 bytes for space followed by 4 * 2 byte color component
//                index += 10;
                YLRGBA *rgba = [YLRGBA new];
                unsigned short int belongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"drop shadow info color space the color belongs to %d",belongs);
                rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                
                NSLog(@"drop shadow info color space is %@", [rgba description]);

                unsigned short int padding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"drop shadow info color space padding %d",padding);
                
                //Blend mode: 4 bytes for signature and 4 bytes for key
//                index += 8;
                NSString *signature = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"drop shadow info blend mode signature is %@", signature);

                NSString *modeKey = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"drop shadow info blend mode key is %@", modeKey);
                
                //Effect enabled
//                index += 1;
                unsigned int enable = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"drop shadow info enable is %d",enable);
                
                //Use this angle in all of the layer effects
//                index += 1;
                unsigned int angleEnable = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"drop shadow info angle is %d",angleEnable);
                
                //Opacity as a percen
//                index += 1;
                unsigned int opacity = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"drop shadow info opacity is %d",opacity);
                
                //Native color: 2 bytes for space followed by 4 * 2 byte color component
//                index += 10;
                YLRGBA *nrgba = [YLRGBA new];
                unsigned short int nbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"drop shadow info Native color space the color belongs to %d",nbelongs);
                rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                
                NSLog(@"drop shadow info Native color space is %@", [nrgba description]);

                unsigned short int npadding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"drop shadow info Native color space padding %d",npadding);
                
            } else if ([@"isdw" isEqualToString:string]) {
#pragma mark ------ ## Effects layer, drop shadow and inner shadow info
                //41 or 51 (depending on version)
                YLEffectLayerInfo *layerInfo = [self parseEffectsInfo:fileData index:&index prefix:@"inner shadow info"];

                unsigned char angle[4] = {0};
                [fileData getBytes:&angle range:NSMakeRange(index, sizeof(angle))];
                unsigned int dsAngle = [YLDataProcess bytesToInt:angle length:sizeof(angle)];

                NSLog(@"inner shadow info Angle in degrees is %d", dsAngle);

                index += sizeof(angle);

                unsigned char distance[4] = {0};
                [fileData getBytes:&distance range:NSMakeRange(index, sizeof(distance))];
                unsigned int dsdis = [YLDataProcess bytesToInt:distance length:sizeof(distance)];

                NSLog(@"inner shadow info Distance in pixels is %d", dsdis);

                index += sizeof(distance);

                //Color: 2 bytes for space followed by 4 * 2 byte color component
//                index += 10;
                YLRGBA *rgba = [YLRGBA new];
                unsigned short int belongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"inner shadow info color space the color belongs to %d",belongs);
                rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                
                NSLog(@"inner shadow info color space is %@", [rgba description]);

                unsigned short int padding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"inner shadow info color space padding %d",padding);

                //Blend mode: 4 bytes for signature and 4 bytes for key
//                index += 8;
                NSString *signature = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"inner shadow info blend mode signature is %@", signature);

                NSString *modeKey = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"inner shadow info blend mode key is %@", modeKey);

                //Effect enabled
//                index += 1;
                unsigned int enable = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"inner shadow info enable is %d",enable);

                //Use this angle in all of the layer effects
//                index += 1;
                unsigned int angleEnable = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"inner shadow info angle is %d",angleEnable);

                //Opacity as a percen
//                index += 1;
                unsigned int opacity = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"inner shadow info opacity is %d",opacity);

                //Native color: 2 bytes for space followed by 4 * 2 byte color component
//                index += 10;
                YLRGBA *nrgba = [YLRGBA new];
                unsigned short int nbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"inner shadow info Native color space the color belongs to %d",nbelongs);
                rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                
                NSLog(@"inner shadow info Native color space is %@", [nrgba description]);

                unsigned short int npadding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"inner shadow info Native color space padding %d",npadding);
            } else if ([@"oglw" isEqualToString:string]) {
#pragma mark ------ ## Effects layer, outer glow info
                //32 for Photoshop 5.0; 42 for 5.5
                YLEffectLayerInfo *layerInfo = [self parseEffectsInfo:fileData index:&index prefix:@"outer glow info"];

                //Color: 2 bytes for space followed by 4 * 2 byte color component
//                index += 10;
                YLRGBA *rgba = [YLRGBA new];
                unsigned short int belongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"outer glow info color space the color belongs to %d",belongs);
                rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                
                NSLog(@"outer glow info color space is %@", [rgba description]);

                unsigned short int padding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"outer glow info color space padding %d",padding);

                //Blend mode: 4 bytes for signature and 4 bytes for key
//                index += 8;
                NSString *signature = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"outer glow info blend mode signature is %@", signature);

                NSString *modeKey = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"outer glow info blend mode key is %@", modeKey);

                //Effect enabled
//                index += 1;
                unsigned int enable = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"outer glow info enable is %d",enable);
                
                //Opacity as a percen
//                index += 1;
                unsigned int opacity = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"outer glow info opacity is %d",opacity);

                if (layerInfo.version == 2) {
                    //Native color: 2 bytes for space followed by 4 * 2 byte color component
//                    index += 10;
                    YLRGBA *nrgba = [YLRGBA new];
                    unsigned short int nbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                    NSLog(@"outer glow info Native color space the color belongs to %d",nbelongs);
                    rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    
                    NSLog(@"outer glow info Native color space is %@", [nrgba description]);

                    unsigned short int npadding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                    NSLog(@"outer glow info Native color space padding %d",npadding);
                }
            } else if ([@"iglw" isEqualToString:string]) {
#pragma mark ------ ## Effects layer, inner glow info
                //33 for Photoshop 5.0; 43 for 5.5
                YLEffectLayerInfo *layerInfo = [self parseEffectsInfo:fileData index:&index prefix:@"inner glow info"];

                //Color: 2 bytes for space followed by 4 * 2 byte color component
//                index += 10;
                YLRGBA *rgba = [YLRGBA new];
                unsigned short int belongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"inner glow info color space the color belongs to %d",belongs);
                rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                
                NSLog(@"inner glow info color space is %@", [rgba description]);

                unsigned short int padding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"inner glow info color space padding %d",padding);

                //Blend mode: 4 bytes for signature and 4 bytes for key
//                index += 8;
                NSString *signature = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"inner glow info blend mode signature is %@", signature);

                NSString *modeKey = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"inner glow info blend mode key is %@", modeKey);
                
                //Effect enabled
//                index += 1;
                unsigned int enable = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"inner glow info enable is %d",enable);

                //Opacity as a percen
//                index += 1;
                unsigned int opacity = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"inner glow info opacity is %d",opacity);
                
                if (layerInfo.version == 2) {
                    //Invert
//                    index += 1;
                    unsigned int invert = [YLFileProcess getByteFromFile:fileData index:&index];
                    NSLog(@"inner glow info invert is %d",invert);
                    
                    //Native color: 2 bytes for space followed by 4 * 2 byte color component
//                    index += 10;
                    YLRGBA *nrgba = [YLRGBA new];
                    unsigned short int nbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                    NSLog(@"inner glow info Native color space the color belongs to %d",nbelongs);
                    nrgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    nrgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    nrgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    
                    NSLog(@"inner glow info Native color space is %@", [nrgba description]);

                    unsigned short int npadding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                    NSLog(@"inner glow info Native color space padding %d",npadding);
                }
                
                if (enable) {
                    [effectDic setObject:@(opacity) forKey:@"opacity"];
                }
            } else if ([@"bevl" isEqualToString:string]) {
#pragma mark ------ ## Effects layer, bevel info
                //58 for version 0, 78 for version 20
                YLEffectLayerInfo *layerInfo = [self parseBaseEffectsInfo:fileData index:&index prefix:@"bevel info"];
                
                //Angle in degrees
                unsigned int angle = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
                NSLog(@"bevel info Angle in degrees is %d", angle);
                
                //Strength. Depth in pixels
                unsigned int strength = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
                NSLog(@"bevel info Strength Depth in pixels is %d", strength);
                
                //Blur value in pixels
                unsigned int blur = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
                NSLog(@"bevel info Blur value in pixels is %d", blur);

                //Highlight blend mode: 4 bytes for signature and 4 bytes for the key
                NSString *highlightsignature = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"bevel info Highlight blend mode signature is %@", highlightsignature);

                NSString *highlightmodeKey = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"bevel info Highlight blend mode key is %@", highlightmodeKey);
                
                //Shadow blend mode: 4 bytes for signature and 4 bytes for the key
                NSString *shadowsignature = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"bevel info blend mode signature is %@", shadowsignature);

                NSString *shadowmodeKey = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"bevel info Shadow blend mode key is %@", shadowmodeKey);
                
                //Highlight Color: 2 bytes for space followed by 4 * 2 byte color component
                YLRGBA *hrgba = [YLRGBA new];
                unsigned short int hbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"bevel info Highlight color space belongs to %d",hbelongs);
                hrgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                hrgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                hrgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                hrgba.alpha = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;

                NSLog(@"bevel info Highlight color space is %@", [hrgba description]);
                
                //Shadow Color: 2 bytes for space followed by 4 * 2 byte color component
                YLRGBA *srgba = [YLRGBA new];
                unsigned short int sbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"bevel info Shadow color space belongs to %d",sbelongs);
                srgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                srgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                srgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                srgba.alpha = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;

                NSLog(@"bevel info Shadow color space is %@", [srgba description]);

                //Bevel style
                unsigned short int style = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"bevel info Bevel style is %d", style);
                
                //Hightlight opacity as a percent
                unsigned short int hopacity = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"bevel info Hightlight opacity is %d", hopacity);
                
                //Shadow opacity as a percent
                unsigned short int sopacity = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"bevel info Shadow opacity is %d", sopacity);
                
                //Effect enabled
                unsigned short int enable = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"bevel info Effect enabled is %d", enable);

                //Use this angle in all of the layer effects
                unsigned short int allUsed = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"bevel info Use this angle in all of the layer effects is %d", allUsed);

                //Up or down
                unsigned short int direct = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"bevel info angle direct is %d", direct);
                
                if (enable) {
                    [dictionary setObject:@(hopacity) forKey:@"hightlight_opacity"];
                    [dictionary setObject:@(sopacity) forKey:@"shadow_opacity"];
                }
                
                if (layerInfo.version == 2) {
                    //Real highlight color: 2 bytes for space followed by 4 * 2 byte color component
                    YLRGBA *rhrgba = [YLRGBA new];
                    unsigned short int rhbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                    NSLog(@"bevel info Real Highlight color space belongs to %d",rhbelongs);
                    rhrgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    rhrgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    rhrgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    rhrgba.alpha = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;

                    NSLog(@"bevel info Real Highlight color space is %@", [rhrgba description]);
                    
                    //Real shadow color: 2 bytes for space followed by 4 * 2 byte color component
                    YLRGBA *rsrgba = [YLRGBA new];
                    unsigned short int rsbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                    NSLog(@"bevel info Real Shadow color space belongs to %d",rsbelongs);
                    rsrgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    rsrgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    rsrgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                    rsrgba.alpha = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;

                    NSLog(@"bevel info Real Shadow color space is %@", [rsrgba description]);
                }
            } else if ([@"sofi" isEqualToString:string]) {
#pragma mark -----  ## Effects layer, solid fill (added in Photoshop 7.0)
                //Size: 34
                YLEffectLayerInfo *layerInfo = [self parseBaseEffectsInfo:fileData index:&index prefix:@"solid fill"];
                
                NSString *signature = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"solid fill signature is %@",signature);
                
                //Key for blend mode
//                index += 4;
                NSString *blendKey = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
                NSLog(@"solid fill blend mode key is %@",blendKey);
                
                //Color space
//                index += 10;
                
                YLRGBA *rgba = [YLRGBA new];
                unsigned short int belongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"solid fill color space the color belongs to %d",belongs);
                rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                
                NSLog(@"solid fill color space is %@", [rgba description]);

                unsigned short int padding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"solid fill color space padding %d",padding);
                
                //Opacity
//                index += 1;
                unsigned int opacity = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"solid fill opacity is %d",opacity);
                rgba.alpha = opacity;
                
                NSLog(@"solid fill Color space is %@",[rgba description]);
                
                //Enabled
//                index += 1;
                unsigned int enable = [YLFileProcess getByteFromFile:fileData index:&index];
                NSLog(@"solid fill enable is %d",enable);
                if (enable) {
                    [effectDic setObject:rgba forKey:@"overlay"];
                }

                //Native color space
//                index += 10;
                unsigned short int nbelongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"solid fill native color space the color belongs to %d",nbelongs);

                unsigned short int nred = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                unsigned short int ngreen = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                unsigned short int nblue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
                
                NSLog(@"solid fill native Color space is r:%d, g:%d, b:%d",nred,ngreen,nblue);
                
                unsigned short int npadding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                NSLog(@"solid fill color space padding %d",npadding);

                index += 2;
            }
            
            if (effectDic.count > 0) {
                [dic setObject:effectDic forKey:string];
            }
        }
        
        if (dic.count > 0) {
            [dictionary setObject:dic forKey:@"result"];
        }

    } else if ([@"vmsk" isEqualToString:string] || [@"vsms" isEqualToString:string]) {
#pragma mark ---- Vector mask setting
        //Version ( = 3 for Photoshop 6.0)
        unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Vector mask setting version is %d", version);
        
        //Flags. bit 1 = invert, bit 2 = not link, bit 3 = disable
        unsigned int flag = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Vector mask setting flag is %d", flag);
        [dictionary setObject:@(flag) forKey:@"records_flag"];
        
#pragma mark ----- #  Path resource format
        [dictionary setObject:@((endIndex - index)/26) forKey:@"records_count"];
        
        NSMutableArray *array = [NSMutableArray array];
        NSMutableDictionary *shape = [NSMutableDictionary dictionary];
        NSMutableArray *points = [NSMutableArray array];
        
        unsigned short int shapeType = 0;
        
        while (index < (endIndex - 25)) {

            unsigned short int recordType = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
            NSLog(@"Path data record type is %d", recordType);
            switch (recordType) {
                //Closed subpath length record
                case 0:
                //Open subpath length record
                case 3:
                {
                    shapeType = recordType;
                    unsigned short int numPoints = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                    NSLog(@"Path data the number of Bezier knot records is %d", numPoints);
                    index += 22;
                    if (points.count > 0) {
                        [shape setObject:points forKey:@"points"];
                        [array addObject:shape];
                        shape = [NSMutableDictionary dictionary];
                        points = [NSMutableArray arrayWithCapacity:numPoints];
                    }
                    [shape setObject:@(numPoints) forKey:@"points_count"];
                    [shape setObject:@(shapeType) forKey:@"shape_type"];
                }
                    break;
                //Closed subpath Bezier knot, linked
                case 1:
                //Closed subpath Bezier knot, unlinked
                case 2:
                //Open subpath Bezier knot, linked
                case 4:
                //Open subpath Bezier knot, unlinked
                case 5:
                {
                    double preceding_vert = [YLFileProcess getPathNumberFromFile:fileData index:&index];
                    double preceding_horiz = [YLFileProcess getPathNumberFromFile:fileData index:&index];
//                    NSLog(@"preceding : %f, %f",preceding_horiz,preceding_vert);
                    double anchor_vert = [YLFileProcess getPathNumberFromFile:fileData index:&index];
                    double anchor_horiz = [YLFileProcess getPathNumberFromFile:fileData index:&index];
//                    NSLog(@"anchor : %f, %f",anchor_horiz,anchor_vert);
                    double leaving_vert = [YLFileProcess getPathNumberFromFile:fileData index:&index];
                    double leaving_horiz = [YLFileProcess getPathNumberFromFile:fileData index:&index];
//                    NSLog(@"leaving : %f, %f",leaving_horiz,leaving_vert);
                    
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:[NSValue valueWithCGPoint:CGPointMake(preceding_horiz, preceding_vert)] forKey:@"preceding"];
                    [dic setObject:[NSValue valueWithCGPoint:CGPointMake(anchor_horiz, anchor_vert)] forKey:@"anchor"];
                    [dic setObject:[NSValue valueWithCGPoint:CGPointMake(leaving_horiz, leaving_vert)] forKey:@"leaving"];
                    [dic setObject:@(recordType) forKey:@"type"];
                    [points addObject:dic];
                }
                    break;
                //Path fill rule record
                case 6:
                {
                    index += 24;
                }
                    break;
                //Clipboard record
                case 7:
                {
                    double top = [YLFileProcess getPathNumberFromFile:fileData index:&index];
                    double left = [YLFileProcess getPathNumberFromFile:fileData index:&index];
                    double bottom = [YLFileProcess getPathNumberFromFile:fileData index:&index];
                    double right = [YLFileProcess getPathNumberFromFile:fileData index:&index];
                    double resolution = [YLFileProcess getPathNumberFromFile:fileData index:&index];
                    index += 4;
                }
                    break;
                //Initial fill rule record
                case 8:
                {
                    unsigned short int initialFill = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
                    NSLog(@"Path data fill starts with all pixels is %d", initialFill);
                    index += 22;
                }
                    break;
                default:
                    index += 24;
                    break;
            }
        }
        
        if (points.count > 0) {
            [shape setObject:points forKey:@"points"];
        }
        if (shape.count > 0) {
            [array addObject:shape];
        }
        if (array.count > 0) {
            NSLog(@"knots count is : %ld",array.count);
            [dictionary setObject:array forKey:@"knots"];
        }
    } else if ([@"lyvr" isEqualToString:string]) {
#pragma mark ---- Layer version (Photoshop 7.0)
            //A 32-bit number representing the version of Photoshop needed to read and interpret the layer without data loss. 70 = 7.0, 80 = 8.0, etc.
            //The minimum value is 70, because just having the field present in 6.0 triggers a warning. For the future, Photoshop 7 checks to see whether this number is larger than the current version -- i.e., 70 -- and if so, warns that it is ignoring some data.)
            unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Layer version version is %d", version);
            
    } else if ([@"patt" isEqualToString:string]) {
#pragma mark ---- Patterns (Photoshop 6.0 and CS (8.0))
        while (index < (endIndex - 4)) {

            unsigned int length = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Pattern length is %d", length);

            NSInteger pattTmpIndex = index;
            
            unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Pattern version is %d", version);
            
            //The image mode of the file. Supported values are: Bitmap = 0; Grayscale = 1; Indexed = 2; RGB = 3; CMYK = 4; Multichannel = 7; Duotone = 8; Lab = 9
            unsigned int mode = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Pattern image mode is %d", mode);
            
            //Point: vertical, 2 bytes and horizontal, 2 bytes
            unsigned short int vertical = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
            NSLog(@"Pattern point vertical is %d", vertical);
            
            unsigned short int horizontal = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
            NSLog(@"Pattern point horizontal is %d", horizontal);
            
            YLPascalString *name = [YLFileProcess getUnicodeStringFromFile:fileData index:&index];
            NSLog(@"Pattern name length is %d",name.length);
            NSLog(@"Pattern name is %@",name.text);
            
            YLPascalString *uniqueID = [YLFileProcess getPascalStringFromFile:fileData index:&index lengthBlock:nil encode:NSUTF8StringEncoding];
            NSLog(@"Pattern uniqueID length is %d",uniqueID.length);
            NSLog(@"Pattern uniqueID is %@",uniqueID.text);
            
            if (mode == 2) {
                //Index color table (256 * 3 RGB values): only present when image mode is indexed color
                index += 256 * 3;
            }
            
            //Pattern data as Virtual Memory Array List
#pragma mark ----  # Virtual Memory Array List
            //Version ( =3)
            unsigned int vmVersion = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Virtual Memory Array List version is %d", vmVersion);
            
            unsigned int vmLength = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Virtual Memory Array List length is %d", vmLength);
            
            NSInteger vmTempIndex = index;

            unsigned int vmTop = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Virtual Memory Array List top is %d", vmTop);
            
            unsigned int vmLeft = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Virtual Memory Array List left is %d", vmLeft);
            
            unsigned int vmBottom = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Virtual Memory Array List bottom is %d", vmBottom);
            
            unsigned int vmRight = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Virtual Memory Array List right is %d", vmRight);
            
            unsigned int vmChannel = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
            NSLog(@"Virtual Memory Array List Number of channels is %d", vmChannel);
            
            //The following is a virtual memory array, repeated for the number of channels + one for a user mask + one for a sheet mask.
            
//            for (NSInteger i=0; i<=(vmChannel+2); i++) {
//
//                
//                //Boolean indicating whether array is written, skip following data if 0.
//                unsigned int skip = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//                NSLog(@"skip following data is %d", skip != 0);
//                if (skip == 0) {
//                    continue;
//                }
//                
//                unsigned int itemLength = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//                NSLog(@"length is %d", itemLength);
//                
//                NSInteger tempIndex = index;
//                if (itemLength == 0) {
//                    continue;
//                }
//                
//                //Pixel depth: 1, 8, 16 or 32
//                unsigned int depth = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//                NSLog(@"pixel depth is %d", depth);
//                
//                unsigned int itemTop = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//                NSLog(@"channel item top is %d", itemTop);
//                
//                unsigned int itemLeft = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//                NSLog(@"channel item left is %d", itemLeft);
//                
//                unsigned int itemBottom = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//                NSLog(@"channel item bottom is %d", itemBottom);
//                
//                unsigned int itemRight = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//                NSLog(@"channel item  right is %d", itemRight);
//                
//                //Pixel depth: 1, 8, 16 or 32
//                unsigned short int pixelDepth = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
//                NSLog(@"pixel depth is %d", pixelDepth);
//                
//                //Compression mode of data to follow. 1 is zip.
//                unsigned short int compression = [YLFileProcess getByteFromFile:fileData index:&index];
//                NSLog(@"compression mode of data is %d", compression);
//                
//                index += tempIndex + itemLength;
//            }
            
            index = vmTempIndex + vmLength;
            
            if (index != (pattTmpIndex + length)) {
                index = pattTmpIndex + length;
            }

        }
    } else if ([@"txt2" isEqualToString:string]) {
#pragma mark ---- Text Engine Data
                
        unsigned int length = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Text Engine Data length is %d", length);
        
#pragma mark ---- * maybe error
        length = (unsigned int)MIN(endIndex-index, length);
        
        unsigned char tdtaContent[length];
        [fileData getBytes:&tdtaContent range:NSMakeRange(index, length)];

        YLPSDEngineData *engineData = [YLPSDEngineData new];
        [engineData parseEngineData:tdtaContent length:length];
                
        index += length;
    } else if ([@"cinf" isEqualToString:string]) {
#pragma mark ---- Compositor Used (Photoshop 2020)
        unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Compositor Used version is %d", version);
        
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        
        if (descriptor.result.count > 0) {
            [dictionary setObject:descriptor.result forKey:@"result"];
        }
    } else if ([@"vscg" isEqualToString:string]) {
#pragma mark ---- Vector Stroke Content Data (Photoshop CS6)
        NSString *vecKey = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
        NSLog(@"Key for Vector Stroke Content Data is %@", vecKey);
        vecKey = [vecKey.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (vecKey) {
            [dictionary setObject:vecKey forKey:@"vscg_key"];
        }
        
        unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Vector Stroke Content Data version is %d", version);
        
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        
        if (descriptor.result.count > 0) {
            [dictionary setObject:descriptor.result forKey:@"result"];
        }
    } else if ([@"vogk" isEqualToString:string]) {
#pragma mark ---- Vector Origination Data (Photoshop CC)
        unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Vector Origination Data Version ( = 1 for Photoshop CC) is %d", version);
        
        unsigned int version1 = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Vector Origination Data version is %d", version1);
        
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        
        if (descriptor.result.count > 0) {
            [dictionary setObject:descriptor.result forKey:@"result"];
        }
    } else if ([@"vstk" isEqualToString:string]) {
#pragma mark ---- Vector Stroke Data (Photoshop CS6)
        unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Vector Stroke Data Version is %d", version);
        
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        
        if (descriptor.result.count > 0) {
            [dictionary setObject:descriptor.result forKey:@"result"];
        }
    } else if ([@"gdfl" isEqualToString:string]) {
#pragma mark ---- Gradient fill setting (Photoshop 6.0)
        //Version ( = 16 for Photoshop 6.0)
        unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Gradient fill setting Version is %d", version);
        
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        
        if (descriptor.result.count > 0) {
            [dictionary setObject:descriptor.result forKey:@"result"];
        }
    } else if ([@"sn2p" isEqualToString:string]) {
#pragma mark ---- Using Aligned Rendering (Photoshop CS6)
        //Non zero is true for using aligned rendering
        unsigned int alignRender = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"using aligned rendering is %d", alignRender);
    } else if ([@"lnk2" isEqualToString:string]) {
#pragma mark ---- Linked Layer
        //Key is 'lnkD' . Also keys 'lnk2' and 'lnk3
        while (index < endIndex) {
            unsigned int length = [YLFileProcess getUnsignedIntFromFile:fileData index:&index length:8];
            NSLog(@"Linked Layer length is %d", length);
            
            index += length;
////( = 'liFD' linked file data, 'liFE' linked file external or 'liFA' linked file alias )
//            unsigned int type = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//            NSLog(@"Linked Layer Type  is %d", type);
//
//            //Version ( = 1 to 7 )
//            unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//            NSLog(@"Linked Layer version  is %d", version);
//
//            YLPascalString *uniqueID = [YLFileProcess getPascalStringFromFile:fileData index:&index lengthBlock:nil encode:NSUTF8StringEncoding];
//            NSLog(@"Linked Layer unique id length is %d", uniqueID.length);
//            NSLog(@"Linked Layer unique id is %@", uniqueID.text);
//
//            YLPascalString *fileName = [YLFileProcess getUnicodeStringFromFile:fileData index:&index];
//            NSLog(@"Linked Layer original file name length is %d", fileName.length);
//            NSLog(@"Linked Layer original file name is %@", fileName.text);
//
//            unsigned int fileType = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//            NSLog(@"Linked Layer file Type is %d", fileType);
//
//            unsigned int fileCreator = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
//            NSLog(@"Linked Layer file Creator is %d", fileCreator);
//
//            unsigned int followlength = [YLFileProcess getUnsignedIntFromFile:fileData index:&index length:8];
//            NSLog(@"Linked Layer follow data length is %d", followlength);
//
//            unsigned int desc = [YLFileProcess getByteFromFile:fileData index:&index];
//            NSLog(@"Linked Layer File open descriptor is %d", desc);
//            
//            YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
//            [descriptor parse:fileData index:index];
//            index = descriptor.endIndex;
            
        }
    } else if ([@"plld" isEqualToString:string]) {
#pragma mark ---- Placed Layer (replaced by SoLd in Photoshop CS3)
        //Type ( = 'plcL' )
        NSString *type = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
        NSLog(@"Placed Layer Type is %@", type);
        
        unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer version is %d", version);
        
        YLPascalString *uniqueID = [YLFileProcess getPascalStringFromFile:fileData index:&index lengthBlock:nil encode:NSUTF8StringEncoding];
        NSLog(@"Placed Layer unique id length is %d", uniqueID.length);
        NSLog(@"Placed Layer unique id is %@", uniqueID.text);
        
        unsigned int pageNum = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer page number is %d", pageNum);
        
        unsigned int total = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer total pages is %d", total);
        
        unsigned int policy = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer Anit alias policy is %d", policy);
        
        //Placed layer type: 0 = unknown, 1 = vector, 2 = raster, 3 = image stack
        unsigned int layerType = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer layer type is %d", layerType);
        
        //XX
        double ttTrans1 = [YLFileProcess getDoubleFromFile:fileData index:&index];
        NSLog(@"Placed Layer ttTrans1 is %f", ttTrans1);
                
        //XY
        double ttTrans2 = [YLFileProcess getDoubleFromFile:fileData index:&index];
        NSLog(@"Placed Layer ttTrans2 is %f", ttTrans2);
                
        //YX
        double ttTrans3 = [YLFileProcess getDoubleFromFile:fileData index:&index];
        NSLog(@"Placed Layer ttTrans3 is %f", ttTrans3);

        //YY
        double ttTrans4 = [YLFileProcess getDoubleFromFile:fileData index:&index];
        NSLog(@"Placed Layer ttTrans4 is %f", ttTrans4);
        
        //XX
        double ttTrans5 = [YLFileProcess getDoubleFromFile:fileData index:&index];
        NSLog(@"Placed Layer ttTrans5 is %f", ttTrans5);
                
        //XY
        double ttTrans6 = [YLFileProcess getDoubleFromFile:fileData index:&index];
        NSLog(@"Placed Layer ttTrans6 is %f", ttTrans6);
                
        //YX
        double ttTrans7 = [YLFileProcess getDoubleFromFile:fileData index:&index];
        NSLog(@"Placed Layer ttTrans7 is %f", ttTrans7);

        //YY
        double ttTrans8 = [YLFileProcess getDoubleFromFile:fileData index:&index];
        NSLog(@"Placed Layer ttTrans8 is %f", ttTrans8);
        
        //Warp version ( = 0 )
        unsigned int warpVer = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer warp version is %d", warpVer);
        
        //Warp descriptor version ( = 16 )
        unsigned int warpDesc = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer warp descriptor version is %d", warpDesc);
        
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        
    } else if ([@"sold" isEqualToString:string]) {
#pragma mark ---- Placed Layer Data (Photoshop CS3)
        NSString *type = [YLFileProcess getStringFromFile:fileData index:&index length:4 encode:NSUTF8StringEncoding];
        NSLog(@"Placed Layer Data Type is %@", type);
        
        unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer Data version is %d", version);
        
        //descriptor version ( = 16 )
        unsigned int desVer = [YLFileProcess getUnsignedIntFromFile:fileData index:&index];
        NSLog(@"Placed Layer Data descriptor version is %d", desVer);
        
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        [descriptor parse:fileData index:index];
        index = descriptor.endIndex;
        
    } else if ([@"fmsk" isEqualToString:string]) {
#pragma mark ---- Filter Mask (Photoshop CS3)
        YLRGBA *rgba = [YLRGBA new];
        rgba.alpha = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
        rgba.red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
        rgba.green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
        rgba.blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index] >> 8;
        index += 2;
        
        //Opacity
        unsigned short int opacity = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
        NSLog(@"Filter Mask opacity is %d",opacity);
        rgba.alpha = opacity;
        
        NSLog(@"Filter Mask Color space is %@",[rgba description]);
        [dictionary setObject:rgba forKey:@"layer_color"];
    } else if ([@"iopa" isEqualToString:string]) {
        unsigned short int opacity = [YLFileProcess getByteFromFile:fileData index:&index];
        NSLog(@"layer fill opacity is %d",opacity);
        [dictionary setObject:@(opacity) forKey:@"mix_opacity"];
    } else if ([YLDataProcess arrayContainString:array string:string]) {
        NSLog(@"adjustment layer info key ~~~~~~~~~~~~~~~~~%@",string);
    } else {
        NSLog(@"adjustment layer info key ~~~~~~~~~~~~~~~~~%@",string);
    }

//    unsigned char a[200] = {0};
//    [fileData getBytes:&a range:NSMakeRange(index, MIN(200, fileData.length - index))];
    
    if (index != endIndex) {
        NSLog(@"addional layer length is not match:%ld,%ld",index,endIndex);
        index = endIndex;
    }
    
    if (dictionary.count > 0) {
        [result setObject:dictionary forKey:_adjustment.key];
        _adjustment.result = result;
    }
    
    _adjustment.endIndex = index;
    self.endIndex = index;
    return YES;
}

- (YLEffectLayerInfo *)parseBaseEffectsInfo:(NSData *)fileData index:(NSInteger *)index prefix:(NSString *)prefix {
    YLEffectLayerInfo *layerInfo = [YLEffectLayerInfo new];

    //Size of the remaining items
    unsigned int size = [YLFileProcess getUnsignedIntFromFile:fileData index:index];
    NSLog(@"%@ Size of the remaining items is %d",prefix,size);
    layerInfo.size = size;

    //Version: 0 ( Photoshop 5.0) or 2 ( Photoshop 5.5)
    unsigned int version = [YLFileProcess getUnsignedIntFromFile:fileData index:index];
    NSLog(@"%@ version is %d", prefix, version);
    layerInfo.version = version;
    
    return layerInfo;
}

- (YLEffectLayerInfo *)parseEffectsInfo:(NSData *)fileData index:(NSInteger *)index prefix:(NSString *)prefix {
    YLEffectLayerInfo *layerInfo = [self parseBaseEffectsInfo:fileData index:index prefix:prefix];

    //Blur value in pixels
    unsigned int blur = [YLFileProcess getUnsignedIntFromFile:fileData index:index];
    NSLog(@"%@ Blur value in pixels is %d", prefix, blur);
    layerInfo.blur = blur;

    //Intensity as a percent
    unsigned int intensity = [YLFileProcess getUnsignedIntFromFile:fileData index:index];
    NSLog(@"%@ Intensity as a percent is %d", prefix, intensity);
    layerInfo.intensity = intensity;
    
    return layerInfo;
}

@end
