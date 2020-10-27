//
//  YLPSDDescriptor.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDDescriptor.h"
#import "YLDataProcess.h"
#import "YLPSDEngineData.h"
#import "YLPascalString.h"
#import "YLFileProcess.h"
#import "YLTextInfo.h"
#import "YLClassObject.h"

@interface YLPSDDescriptor()

@property (nonatomic, strong, readwrite) NSDictionary *result;

@end

@implementation YLPSDDescriptor

#pragma mark --- ## Descriptor structure Text data

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {
    self.startIndex = index;
    
    //name from classid
    unsigned char txClassId[4] = {0};
    [fileData getBytes:&txClassId range:NSMakeRange(index, sizeof(txClassId))];
    unsigned int textLength = [YLDataProcess bytesToInt:txClassId length:sizeof(txClassId)];

    NSLog(@"Descriptor structure name length is %d", textLength);

    index += sizeof(txClassId);

    textLength *= 2;
    unsigned char textName[textLength];
    [fileData getBytes:&textName range:NSMakeRange(index, textLength)];
    NSData *data = [NSData dataWithBytes:textName length:textLength];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];

    NSLog(@"Descriptor structure name is %@", string);

    index += textLength;
    
//    YLPascalString *textName = [YLFileProcess getUnicodeStringFromFile:fileData index:&index];
//    NSLog(@"Descriptor structure length is %d", textName.length);
//    NSLog(@"Descriptor structure name is %@", textName.text);
    
    //classID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
    unsigned char dClassID[4] = {0};
    [fileData getBytes:&dClassID range:NSMakeRange(index, sizeof(dClassID))];
    unsigned int desLength = [YLDataProcess bytesToInt:dClassID length:sizeof(dClassID)];

    NSLog(@"Descriptor structure descriptor class id length is %d", desLength);

    index += sizeof(dClassID);

    if (desLength == 0) {
        desLength = 4;
    }

    unsigned char descName[desLength];
    [fileData getBytes:&descName range:NSMakeRange(index, desLength)];
    data = [NSData dataWithBytes:descName length:desLength];
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"Descriptor structure descriptor name is %@", string);

    index += desLength;
    
    //Number of items in descriptor
    unsigned char desNum[4] = {0};
    [fileData getBytes:&desNum range:NSMakeRange(index, sizeof(desNum))];
    unsigned int descNumber = [YLDataProcess bytesToInt:desNum length:sizeof(desNum)];
    
    NSLog(@"Number of items in descriptor is %d", descNumber);
    
    index += sizeof(desNum);
    
    string = [string.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *type = string;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSInteger j=0; j<descNumber; j++) {
                
        unsigned char dTypeLen[4] = {0};
        [fileData getBytes:&dTypeLen range:NSMakeRange(index, sizeof(dTypeLen))];
        unsigned int dTypeLength = [YLDataProcess bytesToInt:dTypeLen length:sizeof(dTypeLen)];
        
        NSLog(@"descriptor type key length is %d", dTypeLength);
        
        index += sizeof(dTypeLen);
        
        if (dTypeLength == 0) {
            dTypeLength = 4;
        }
        
        unsigned char dTypeKey[dTypeLength];
        [fileData getBytes:&dTypeKey range:NSMakeRange(index, dTypeLength)];
        data = [NSData dataWithBytes:dTypeKey length:dTypeLength];
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"descriptor type key is %@", string);
        string = [string.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        index += dTypeLength;
        
        NSMutableDictionary *dic = [self parseItem:fileData index:&index string:nil];
        if (dic == nil) {
            array = nil;
            break;
        } else if (dic.count > 0) {
            NSMutableDictionary *value = [NSMutableDictionary dictionaryWithObject:dic forKey:string];
            [array addObject:value];
        }
    }
    
    if (type.length > 0 && array) {
        self.result = [NSDictionary dictionaryWithObject:array forKey:type];
    }
    self.endIndex = index;
    return array != nil;
}

- (NSMutableDictionary *)parseItem:(NSData *)fileData index:(NSInteger *)index string:(NSString *)string {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    BOOL parseSucceed = YES;

    NSData *data;
    NSInteger currentIndex = *index;
    
    if (!string) {
        unsigned char ditem[4] = {0};
        [fileData getBytes:&ditem range:NSMakeRange(currentIndex, sizeof(ditem))];
        data = [NSData dataWithBytes:ditem length:sizeof(ditem)];
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"descriptor item key is %@", string);
        
        currentIndex += sizeof(ditem);
    }
    
    string = [string.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *type = string;
    
    if ([@"text" isEqualToString:string]) {
        //name from classid
//        unsigned char txLen[4] = {0};
//        [fileData getBytes:&txLen range:NSMakeRange(index, sizeof(txLen))];
//        unsigned int txLength = [YLDataProcess bytesToInt:txLen length:sizeof(txLen)];
//
//        NSLog(@"text length is %d", txLength);
//
//        index += sizeof(txLen);
//
//        if (txLength > 0) {
//            txLength *= 2;
//            unsigned char txName[txLength];
//            [fileData getBytes:&txName range:NSMakeRange(index, txLength)];
//            data = [NSData dataWithBytes:txName length:txLength];
//            string = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
//
//            NSLog(@"text name is %@", string);
//
//            index += txLength + 2;
//        }
        YLPascalString *txName = [YLFileProcess getUnicodeStringFromFile:fileData index:&currentIndex];
        NSLog(@"text length is %d", txName.length);
        NSLog(@"text name is %@", txName.text);
        [dic setObject:txName forKey:type];
    } else if ([@"enum" isEqualToString:string]) {
        unsigned char dEnumName[4] = {0};
        [fileData getBytes:&dEnumName range:NSMakeRange(currentIndex, sizeof(dEnumName))];
        unsigned int dENameLength = [YLDataProcess bytesToInt:dEnumName length:sizeof(dEnumName)];
        
        NSLog(@"enum name length is %d", dENameLength);
        
        currentIndex += sizeof(dEnumName);
        
        if (dENameLength == 0) {
            dENameLength = 4;
        }
        
//        unsigned char dENameKey[dENameLength];
//        [fileData getBytes:&dENameKey range:NSMakeRange(currentIndex, dENameLength)];
//        data = [NSData dataWithBytes:dENameKey length:dENameLength];
//        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *enumName = [YLFileProcess getStringFromFile:fileData index:&currentIndex length:dENameLength encode:NSUTF8StringEncoding];
        NSLog(@"enum class name is %@", enumName);
        
//        currentIndex += dENameLength;
        
        unsigned char dEnumCID[4] = {0};
        [fileData getBytes:&dEnumCID range:NSMakeRange(currentIndex, sizeof(dEnumCID))];
        unsigned int dECIDLength = [YLDataProcess bytesToInt:dEnumCID length:sizeof(dEnumCID)];
        
        NSLog(@"enum class id length is %d", dECIDLength);
        
        currentIndex += sizeof(dEnumCID);
        
        if (dECIDLength == 0) {
            dECIDLength = 4;
        }
        
//        unsigned char dEnumCIDKey[dECIDLength];
//        [fileData getBytes:&dEnumCIDKey range:NSMakeRange(currentIndex, dECIDLength)];
//        data = [NSData dataWithBytes:dEnumCIDKey length:dECIDLength];
//        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"enum class name is %@", string);
        NSString *enumClassName = [YLFileProcess getStringFromFile:fileData index:&currentIndex length:dECIDLength encode:NSUTF8StringEncoding];
        NSLog(@"enum class id name is %@", enumClassName);

        if (enumClassName) {
            [dic setObject:enumClassName forKey:type];
        }
        
//        currentIndex += dECIDLength;
    } else if ([@"objc" isEqualToString:string]) {
        YLPSDDescriptor *descriptor = [YLPSDDescriptor new];
        parseSucceed = [descriptor parse:fileData index:currentIndex];
        currentIndex = descriptor.endIndex;
        if (descriptor.result.count > 0) {
            [dic setObject:descriptor.result forKey:type];
        }
    } else if ([@"untf" isEqualToString:string]) {
        unsigned char dUFID[4] = {0};
        [fileData getBytes:&dUFID range:NSMakeRange(currentIndex, sizeof(dUFID))];
        data = [NSData dataWithBytes:dUFID length:sizeof(dUFID)];
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"unit double type is %@", string);
        
        currentIndex += sizeof(dUFID);
        
        unsigned char dUFValue[8] = {0};
        [fileData getBytes:&dUFValue range:NSMakeRange(currentIndex, sizeof(dUFValue))];
        double dUFIDValue = [YLDataProcess byteToDouble:dUFValue];
        NSLog(@"unit double value is %f", dUFIDValue);
        
        currentIndex += sizeof(dUFValue);
        [dic setObject:@(dUFIDValue) forKey:type];
    } else if ([@"unfl" isEqualToString:string]) {
        unsigned char dUFID[4] = {0};
        [fileData getBytes:&dUFID range:NSMakeRange(currentIndex, sizeof(dUFID))];
        data = [NSData dataWithBytes:dUFID length:sizeof(dUFID)];
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSLog(@"unit float type is %@", string);

        currentIndex += sizeof(dUFID);

        unsigned char dUFValue[4] = {0};
        [fileData getBytes:&dUFValue range:NSMakeRange(currentIndex, sizeof(dUFValue))];
        double dUFIDValue = [YLDataProcess byteToDouble:dUFValue];
        NSLog(@"unit float value is %f", dUFIDValue);

        currentIndex += sizeof(dUFValue);
        [dic setObject:@(dUFIDValue) forKey:type];
    } else if ([@"long" isEqualToString:string]) {
                
        unsigned char dLong[4] = {0};
        [fileData getBytes:&dLong range:NSMakeRange(currentIndex, sizeof(dLong))];
        unsigned int dLongValue = [YLDataProcess bytesToInt:dLong length:sizeof(dLong)];
        
        NSLog(@"long value is %d", dLongValue);
        
        currentIndex += sizeof(dLong);
        [dic setObject:@(dLongValue) forKey:type];
    } else if ([@"tdta" isEqualToString:string]) {
//        unsigned char tdtaLen[4] = {0};
//        [fileData getBytes:&tdtaLen range:NSMakeRange(currentIndex, sizeof(tdtaLen))];
//        unsigned int tdtaLength = [YLDataProcess bytesToInt:tdtaLen length:sizeof(tdtaLen)];
        unsigned int tdtaLength = [YLFileProcess getUnsignedIntFromFile:fileData index:&currentIndex];
        NSLog(@"raw data length is %d", tdtaLength);
        
//        currentIndex += sizeof(tdtaLen);
        
        unsigned char tdtaContent[tdtaLength];
//        unsigned char *tdtaContent = (unsigned char *)malloc(tdtaLength * sizeof(unsigned char));
        [fileData getBytes:&tdtaContent range:NSMakeRange(currentIndex, tdtaLength)];
        
        YLPSDEngineData *engineData = [YLPSDEngineData new];
        NSDictionary *jsonDict = [engineData parseEngineData:tdtaContent length:tdtaLength];
        
//        free(tdtaContent);
        
        currentIndex += tdtaLength;
        
        NSMutableDictionary *styleDic = [NSMutableDictionary dictionary];
        NSMutableArray *styleArray = [NSMutableArray array];
        YLTextInfo *textInfo = [YLTextInfo new];
        NSString *text = [[jsonDict[@"EngineDict"] objectForKey:@"Editor"] objectForKey:@"Text"];
        textInfo.text = [text stringByReplacingOccurrencesOfString:@"*#r#*" withString:@"\r"];
        NSLog(@"text is %@", textInfo.text);

        NSArray *styleSheets = [[jsonDict[@"EngineDict"] objectForKey:@"StyleRun"] objectForKey:@"RunArray"];
        BOOL isLeading = NO;
        for (NSDictionary *dic in styleSheets) {
            YLTextInfo *textStyle = [YLTextInfo new];
            NSDictionary *styleSheetData = [dic[@"StyleSheet"] objectForKey:@"StyleSheetData"];
            NSLog(@"font weight is bold %@", [styleSheetData objectForKey:@"FauxBold"]);
            NSLog(@"font size is %@", [styleSheetData objectForKey:@"FontSize"]);
            textStyle.isBold = [@"true" isEqualToString:[styleSheetData objectForKey:@"FauxBold"]];
            textStyle.fontSize = [[styleSheetData objectForKey:@"FontSize"] floatValue];
            textStyle.autoKerning = [@"true" isEqualToString:[styleSheetData objectForKey:@"AutoKerning"]];
            textStyle.fillColor = [YLRGBA createRGBAColor:[[styleSheetData objectForKey:@"FillColor"] objectForKey:@"Values"]];
            textStyle.stokeColor = [YLRGBA createRGBAColor:[[styleSheetData objectForKey:@"StokeColor"] objectForKey:@"Values"]];
            if (!isLeading) {
                isLeading = YES;
                textInfo.leading = [[styleSheetData objectForKey:@"Leading"] floatValue] - textStyle.fontSize;
            }
            [styleArray addObject:textStyle];
        }
        
        NSInteger startIndex = 0;
        NSArray *lengthArray = [[jsonDict[@"EngineDict"] objectForKey:@"StyleRun"] objectForKey:@"RunLengthArray"];
        for (NSInteger i=0; i<lengthArray.count; i++) {
            YLTextInfo *textStyle = [styleArray objectAtIndex:i];
            textStyle.startIndex = startIndex;
            textStyle.textLength = [[lengthArray objectAtIndex:i] integerValue];
            startIndex += textStyle.textLength;
        }
        
        [styleDic setObject:styleArray forKey:@"text_info"];
        styleArray = [NSMutableArray array];
        
        NSArray *runAlignArray = [[jsonDict[@"EngineDict"] objectForKey:@"ParagraphRun"] objectForKey:@"RunArray"];
        for (NSDictionary *dic in runAlignArray) {
            YLTextInfo *textStyle = [YLTextInfo new];
            NSDictionary *properties = [dic[@"ParagraphSheet"] objectForKey:@"Properties"];
            NSLog(@"text alignment is %@", [properties objectForKey:@"Justification"]);
            if ([properties objectForKey:@"Justification"]) {
                textStyle.alignment = [[properties objectForKey:@"Justification"] integerValue];
            }
            [styleArray addObject:textStyle];
        }
        
        NSArray *alignLengthArray = [[jsonDict[@"EngineDict"] objectForKey:@"ParagraphRun"] objectForKey:@"RunLengthArray"];
        for (NSInteger i=0; i<alignLengthArray.count; i++) {
            YLTextInfo *textStyle = [styleArray objectAtIndex:i];
            textStyle.startIndex = startIndex;
            textStyle.textLength = [[alignLengthArray objectAtIndex:i] integerValue];
            startIndex += textStyle.textLength;
        }
        
        [styleDic setObject:styleArray forKey:@"text_align"];
        textInfo.styles = styleDic;

        NSArray *fontSet = [jsonDict[@"ResourceDict"] objectForKey:@"FontSet"];
        for (NSDictionary *dic in fontSet) {
            NSLog(@"font name is %@", [dic objectForKey:@"Name"]);
        }
        [dic setObject:textInfo forKey:type];
    } else if ([@"doub" isEqualToString:string]) {
        unsigned char ddValue[8] = {0};
        [fileData getBytes:&ddValue range:NSMakeRange(currentIndex, sizeof(ddValue))];
        double dDoubValue = [YLDataProcess byteToDouble:ddValue];
        NSLog(@"double value is %f", dDoubValue);
        
        currentIndex += sizeof(ddValue);
        [dic setObject:@(dDoubValue) forKey:type];
    } else if ([@"bool" isEqualToString:string]) {
        unsigned char boolValue[1] = {0};
        [fileData getBytes:&boolValue range:NSMakeRange(currentIndex, sizeof(boolValue))];
        unsigned int dBoolValue = [YLDataProcess bytesToInt:boolValue length:sizeof(boolValue)];
        NSLog(@"Boolean is %d", dBoolValue != 0);

        currentIndex += sizeof(boolValue);
        [dic setObject:@(dBoolValue) forKey:type];
    } else if ([@"vlls" isEqualToString:string]) {
        unsigned char count[4] = {0};
        [fileData getBytes:&count range:NSMakeRange(currentIndex, sizeof(count))];
        unsigned int listCount = [YLDataProcess bytesToInt:count length:sizeof(count)];
        NSLog(@"list count is %d", listCount);

        currentIndex += sizeof(count);
        
        NSMutableArray *array = [NSMutableArray array];
        for (unsigned int i=0; i<listCount; i++) {
            NSMutableDictionary *listDic = [self parseItem:fileData index:&currentIndex string:nil];
            if (listDic) {
                [array addObject:listDic];
            }
        }
        if (array.count > 0) {
            [dic setObject:array forKey:type];
        }
    } else if ([@"idnt" isEqualToString:string]) {
        unsigned int value = [YLFileProcess getUnsignedIntFromFile:fileData index:&currentIndex];
        NSLog(@"Identifier int is %d", value);
        [dic setObject:@(value) forKey:type];
    }
    else if ([@"obar" isEqualToString:string]) {

        unsigned int count = [YLFileProcess getUnsignedIntFromFile:fileData index:&currentIndex];
        NSLog(@"obar object array count is %d", count);
        
//        NSMutableArray *array = [NSMutableArray array];
        YLPascalString *objc = [YLFileProcess getUnicodeStringFromFile:fileData index:&currentIndex];
        NSLog(@"obar object array class name is %@", objc.text);
        
        YLPascalString *obarID = [YLFileProcess getIDStringFromFile:fileData index:&currentIndex lengthBlock:^unsigned int(unsigned int length) {
            if (length == 0) {
                length = 4;
            }
            return length;
        } encode:NSASCIIStringEncoding];
        
        NSLog(@"obar object array class id string is %@", obarID.text);
        
        unsigned int items = [YLFileProcess getUnsignedIntFromFile:fileData index:&currentIndex];
        NSLog(@"obar object array number of items in each object is %d", items);
        
        for (NSInteger j = 0; j < items; j++) {
            YLPascalString *itemID = [YLFileProcess getIDStringFromFile:fileData index:&currentIndex lengthBlock:^unsigned int(unsigned int length) {
                if (length == 0) {
                    length = 4;
                }
                return length;
            } encode:NSASCIIStringEncoding];
            
            NSLog(@"Object array key-item pair id string is %@", itemID.text);

            NSString *itemType = [YLFileProcess getStringFromFile:fileData index:&currentIndex length:4 encode:NSASCIIStringEncoding];
            NSLog(@"Object array key-item pair item type is %@",itemType);
            
            if ([@"unfl" isEqualToString:itemType.lowercaseString]) {
                NSString *unitID = [YLFileProcess getStringFromFile:fileData index:&currentIndex length:4 encode:NSASCIIStringEncoding];
                NSLog(@"item unit id is %@",unitID);

                unsigned int number = [YLFileProcess getUnsignedIntFromFile:fileData index:&currentIndex];
                NSLog(@"Number of doubles is %d", items);
                
                currentIndex += (number * 8);
            }
        }
    }
    else {
        NSLog(@"type is not parse: %@",string);
        *index = currentIndex;
        return nil;
    }
    *index = currentIndex;
    return parseSucceed?dic:nil;
}

@end
