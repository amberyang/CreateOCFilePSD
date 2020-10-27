//
//  YLPSDImageResourceBlock.m
//  ReadPSD
//
//  Created by amber on 2019/12/5.
//  Copyright © 2019 amber. All rights reserved.
//

#import "YLPSDImageResourceBlock.h"
#import "YLDataProcess.h"
#import "YLFileProcess.h"

@interface YLPSDImageResourceBlock()<NSXMLParserDelegate>

@property (nonatomic, strong, readwrite) YLPSDImageResourceBlockInfo *blockInfo;

@end


@implementation YLPSDImageResourceBlock

- (BOOL)parse:(NSData *)fileData index:(NSInteger)index {
    
    self.startIndex = index;
    
    _blockInfo = [YLPSDImageResourceBlockInfo new];
    _blockInfo.startIndex = index;
            
    //Photoshop always uses its signature, 8BIM.
    unsigned char imageType[4] = {0};
    [fileData getBytes:&imageType range:NSMakeRange(index, sizeof(imageType))];
    NSData *data = [NSData dataWithBytes:imageType length:sizeof(imageType)];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"image type is %@", string);
    _blockInfo.signature = string;
    
    index += sizeof(imageType);
    
    //Unique identifier
    unsigned char imageID[2] = {0};
    [fileData getBytes:&imageID range:NSMakeRange(index, sizeof(imageID))];
    unsigned short int image_id = [YLDataProcess bytesToInt:imageID length:sizeof(imageID)];
    NSLog(@"unique identifier is %d", image_id);
    _blockInfo.resourceId = image_id;
    
    index += sizeof(imageID);
    
    YLPascalString *name = [YLPascalString new];
    
    unsigned char imgNameLength[1] = {0};
    [fileData getBytes:&imgNameLength range:NSMakeRange(index, sizeof(imgNameLength))];
    unsigned short int imageNameLength = [YLDataProcess bytesToInt:imgNameLength length:sizeof(imgNameLength)];
    short int imgnLength = (short int)((imageNameLength + 1) & ~0x01) - 1;
    if (imgnLength <= 0) {
        imgnLength = 1;
    }
    NSLog(@"image name length is %d", imageNameLength);
    name.length = imageNameLength;
    
    index += sizeof(imgNameLength);

    data = [fileData subdataWithRange:NSMakeRange(index, imgnLength)];
    string = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
    NSLog(@"image name is %@", string);
    name.text = string;
    _blockInfo.name = name;
    
    index += imgnLength;
    
    unsigned char imgResSize[4] = {0};
    [fileData getBytes:&imgResSize range:NSMakeRange(index, sizeof(imgResSize))];
    unsigned int imageResSize = [YLDataProcess bytesToInt:imgResSize length:sizeof(imgResSize)];
    imageResSize = (imageResSize + 1) & ~0x01;
    NSLog(@"image size is %d", imageResSize);
    _blockInfo.size = imageResSize;
    
    NSInteger irTempIndex = index;
    index += sizeof(imgResSize);
    
    if (image_id >= 2000 && image_id <= 2997) {

    } else {
        if (image_id == 1005) {
            //Fixed 类型,Horizontal resolution in pixels per inch.
            unsigned char hRes[4] = {0};
            [fileData getBytes:&hRes range:NSMakeRange(index, sizeof(hRes))];
            unsigned int rinHRes = [YLDataProcess bytesToInt:hRes length:sizeof(hRes)];
            rinHRes =  rinHRes/(1<<16);
            NSLog(@"Horizontal resolution in pixels per inch is %d", rinHRes);
            
            index += sizeof(hRes);
            
            //1=display horitzontal resolution in pixels per inch; 2=dis- play horitzontal resolution in pixels per cm.
            unsigned char hResUnit[2] = {0};
            [fileData getBytes:&hResUnit range:NSMakeRange(index, sizeof(hResUnit))];
            unsigned short int riHResUnit = [YLDataProcess bytesToInt:hResUnit length:sizeof(hResUnit)];
            NSLog(@"Horizontal resolution in pixels type is %d", riHResUnit);
            
            index += sizeof(hResUnit);
            
            //Display width as 1=inches; 2=cm; 3=points; 4=picas; 5=col- umns.
            unsigned char widthUnit[2] = {0};
            [fileData getBytes:&widthUnit range:NSMakeRange(index, sizeof(widthUnit))];
            unsigned short int riWidthUnit = [YLDataProcess bytesToInt:widthUnit length:sizeof(widthUnit)];
            NSLog(@"Display width is %d", riWidthUnit);
            
            index += sizeof(widthUnit);
            
            //Fixed 类型,Vertial resolution in pixels per inch
            unsigned char vRes[4] = {0};
            [fileData getBytes:&vRes range:NSMakeRange(index, sizeof(vRes))];
            unsigned int rinVRes = [YLDataProcess bytesToInt:vRes length:sizeof(vRes)];
            rinVRes =  rinVRes/(1<<16);
            NSLog(@"Vertial resolution in pixels per inch is %d", rinVRes);
            
            index += sizeof(hRes);
            
            //1=display vertical resolution in pixels per inch; 2=display vertical resolution in pixels per cm.
            unsigned char vResUnit[2] = {0};
            [fileData getBytes:&vResUnit range:NSMakeRange(index, sizeof(vResUnit))];
            unsigned short int riVResUnit = [YLDataProcess bytesToInt:vResUnit length:sizeof(vResUnit)];
            NSLog(@"Vertial resolution in pixels type is %d", riVResUnit);
            
            index += sizeof(vResUnit);
            
            //Display height as 1=inches; 2=cm; 3=points; 4=picas; 5=col-umns.
            unsigned char heightUnit[2] = {0};
            [fileData getBytes:&heightUnit range:NSMakeRange(index, sizeof(heightUnit))];
            unsigned short int riHeightUnit = [YLDataProcess bytesToInt:heightUnit length:sizeof(heightUnit)];
            NSLog(@"Display height is %d", riHeightUnit);
            
            index += sizeof(heightUnit);
            
        } else if (image_id == 1032) {
#pragma mark  ---  # Grid and guides resource format
#pragma mark  ---  ## Grid and guide header
            unsigned char gridVer[4] = {0};
            [fileData getBytes:&gridVer range:NSMakeRange(index, sizeof(gridVer))];
            unsigned int gridVersion = [YLDataProcess bytesToInt:gridVer length:sizeof(gridVer)];
            NSLog(@"Grid and guide header version is %d", gridVersion);
    
            index += sizeof(gridVer);
    
            unsigned char gridCycle[8] = {0};
            [fileData getBytes:&gridCycle range:NSMakeRange(index, sizeof(gridCycle))];
    
            index += sizeof(gridCycle);
    
            unsigned char gidCount[4] = {0};
            [fileData getBytes:&gidCount range:NSMakeRange(index, sizeof(gidCount))];
            unsigned int guideCount = [YLDataProcess bytesToInt:gidCount length:sizeof(gidCount)];
            NSLog(@"Grid and guide header guideCount is %d", guideCount);
    
            index += sizeof(gidCount);
    
#pragma mark  ---  ## Guide resource block
    
            for (NSInteger i=0; i<guideCount; i++) {
                unsigned char grCor[4] = {0};
                [fileData getBytes:&grCor range:NSMakeRange(index, sizeof(grCor))];
    
                index += sizeof(grCor);
    
                unsigned char grDir[1] = {0};
                [fileData getBytes:&grDir range:NSMakeRange(index, sizeof(grDir))];
                unsigned int guideDir = [YLDataProcess bytesToInt:grDir length:sizeof(grDir)];
                NSLog(@"Guide resource block direction of guide is %d", guideDir);
    
                index += sizeof(grDir);
            }
        } else if (image_id == 1036 || image_id == 1033) {
#pragma mark  ---  # Thumbnail resource format
#pragma mark  ---  ## Thumbnail resource header
            //Format. 1 = kJpegRGB . Also supports kRawRGB (0).
            unsigned char trFormat[4] = {0};
            [fileData getBytes:&trFormat range:NSMakeRange(index, sizeof(trFormat))];
            unsigned int thFormat = [YLDataProcess bytesToInt:trFormat length:sizeof(trFormat)];
            NSLog(@"Thumbnail resource header format is %d", thFormat);
            
            index += sizeof(trFormat);
            
            //Width of thumbnail in pixels.
            unsigned char trWidth[4] = {0};
            [fileData getBytes:&trWidth range:NSMakeRange(index, sizeof(trWidth))];
            unsigned int thWidth = [YLDataProcess bytesToInt:trWidth length:sizeof(trWidth)];
            NSLog(@"Width of thumbnail in pixels is %d", thWidth);
            
            index += sizeof(trWidth);

            //Height of thumbnail in pixels.
            unsigned char trHeight[4] = {0};
            [fileData getBytes:&trHeight range:NSMakeRange(index, sizeof(trHeight))];
            unsigned int thHeight = [YLDataProcess bytesToInt:trHeight length:sizeof(trHeight)];
            NSLog(@"height of thumbnail in pixels is %d", thHeight);
            
            index += sizeof(trHeight);
            
            //Widthbytes: Padded row bytes = (width * bits per pixel + 31) / 32 * 4.
            unsigned char trwb[4] = {0};
            [fileData getBytes:&trwb range:NSMakeRange(index, sizeof(trwb))];
            unsigned int thwb = [YLDataProcess bytesToInt:trwb length:sizeof(trwb)];
            NSLog(@"Widthbytes: Padded row bytes is %d", thwb);
            
            index += sizeof(trwb);
            
            //Total size = widthbytes * height * planes
            unsigned char trTotal[4] = {0};
            [fileData getBytes:&trTotal range:NSMakeRange(index, sizeof(trTotal))];
            unsigned int thTotal = [YLDataProcess bytesToInt:trTotal length:sizeof(trTotal)];
            NSLog(@"Total size is %d", thTotal);
            
            index += sizeof(trTotal);
            
            //Size after compression. Used for consistency check.
            unsigned char trCheck[4] = {0};
            [fileData getBytes:&trCheck range:NSMakeRange(index, sizeof(trCheck))];
            unsigned int thCheck = [YLDataProcess bytesToInt:trCheck length:sizeof(trCheck)];
            NSLog(@"Size after compression is %d", thCheck);
            
            index += sizeof(trCheck);
            
            //Bits per pixel. = 24
            unsigned char trBPP[2] = {0};
            [fileData getBytes:&trBPP range:NSMakeRange(index, sizeof(trBPP))];
            unsigned int thBPP = [YLDataProcess bytesToInt:trBPP length:sizeof(trBPP)];
            NSLog(@"Bits per pixel is %d", thBPP);
            
            index += sizeof(trBPP);
            
            //Number of planes. = 1
            unsigned char trpNum[2] = {0};
            [fileData getBytes:&trpNum range:NSMakeRange(index, sizeof(trpNum))];
            unsigned int thpNum = [YLDataProcess bytesToInt:trpNum length:sizeof(trpNum)];
            NSLog(@"Number of planes is %d", thpNum);
            
            index += sizeof(trpNum);
            
#pragma mark ---- * leave 5 bytes

        } else if (image_id == 1050) {
#pragma mark ---- Slices resource format
        } else if (image_id == 1025) {
            
        } else if (image_id == 1060) {
            data = [fileData subdataWithRange:NSMakeRange(index, imageResSize)];
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                NSLog(@"xml is %@", string);
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
            [xmlParser setDelegate:self];
            [xmlParser parse];
        } else if (image_id == 1062) {
            //(0 = centered, 1 = size to fit, 2 = user defined)
            unsigned char bstyle[2] = {0};
            [fileData getBytes:&bstyle range:NSMakeRange(index, sizeof(bstyle))];
            unsigned short int byteStyle = [YLDataProcess bytesToInt:bstyle length:sizeof(bstyle)];
            NSLog(@"byte style is %d", byteStyle);
            
            index += sizeof(bstyle);
            
            //x location
            unsigned char xLoc[2] = {0};
            [fileData getBytes:&xLoc range:NSMakeRange(index, sizeof(xLoc))];
            float xLocation = 0.0;
            memcpy(&xLocation, xLoc, sizeof(float));
            NSLog(@"x location is %f", xLocation);
            
            index += sizeof(xLoc);
            
            //y location
            unsigned char yLoc[2] = {0};
            [fileData getBytes:&yLoc range:NSMakeRange(index, sizeof(yLoc))];
            float yLocation = 0.0;
            memcpy(&yLocation, yLoc, sizeof(float));
            NSLog(@"y location is %f", yLocation);
            
            index += sizeof(yLoc);
            
            //y location
            unsigned char scale[2] = {0};
            [fileData getBytes:&scale range:NSMakeRange(index, sizeof(scale))];
            float printScale = 0.0;
            memcpy(&printScale, yLoc, sizeof(float));
            NSLog(@"print scale is %f", printScale);
            
            index += sizeof(scale);
        } else if (image_id == 1065) {
            
        } else if (image_id == 1077) {
            //DisplayInfo Color spaces
            unsigned char clSpace[2] = {0};
            [fileData getBytes:&clSpace range:NSMakeRange(index, sizeof(clSpace))];
            unsigned short int colorSpace = [YLDataProcess bytesToInt:clSpace length:sizeof(clSpace)];
            NSLog(@"display info color space is %d", colorSpace);
            
            index += sizeof(clSpace);
            
            //DisplayInfo Color spaces
            unsigned char diColor[8] = {0};
            [fileData getBytes:&diColor range:NSMakeRange(index, sizeof(diColor))];
            
            index += sizeof(diColor);
            
            //DisplayInfo Color spaces
            unsigned char diOpacity[2] = {0};
            [fileData getBytes:&diOpacity range:NSMakeRange(index, sizeof(diOpacity))];
            unsigned short int disOpa = [YLDataProcess bytesToInt:diOpacity length:sizeof(diOpacity)];
            NSLog(@"display info opacity is %d", disOpa);
            
            index += sizeof(diOpacity);
            
            //DisplayInfo Color spaces
            unsigned char diKind[1] = {0};
            [fileData getBytes:&diKind range:NSMakeRange(index, sizeof(diKind))];
            unsigned int disKind = [YLDataProcess bytesToInt:diKind length:sizeof(diKind)];
            NSLog(@"display info kind is %d", disKind);
            
            index += sizeof(diKind);
            
            //DisplayInfo Color spaces
            unsigned char diPad[1] = {0};
            [fileData getBytes:&diPad range:NSMakeRange(index, sizeof(diPad))];
            unsigned int disPad = [YLDataProcess bytesToInt:diPad length:sizeof(diPad)];
            NSLog(@"display info padding is %d", disPad);
            
            index += sizeof(diPad);
#pragma mark ---- * leave 5 bytes
        } else if (image_id == 1028) {
            
        } else if (image_id == 1061) {
                   
        } else if (image_id == 1082) {
            
        } else if (image_id == 1083) {
                   
        } else if (image_id == 1010) {
#pragma mark ----- color structure
            //Color space IDs 0 - RGB, 1 - HSB, 2 - CMYK, 7 - Lab, 8 - Grayscale
            unsigned short int belongs = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
            NSLog(@"The color space the color belongs to %d",belongs);
            //Four short unsigned integers with the actual color data. If the color does not require four values, the extra values are undefined and should be written as zeros
            unsigned short int red = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
            NSLog(@"actual color data red %d",red);
            unsigned short int green = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
            NSLog(@"actual color data green %d",green);
            unsigned short int blue = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
            NSLog(@"actual color data blue %d",blue);
            unsigned short int padding = [YLFileProcess getUnsignedShortIntFromFile:fileData index:&index];
            NSLog(@"actual color data padding %d",padding);
        } else if (image_id == 1037) {
                   
        } else if (image_id == 1049) {
            
        } else if (image_id == 1011) {
                   
        } else if (image_id == 10000) {
            
        } else if (image_id == 1013) {
                   
        } else if (image_id == 1016) {
            
        } else if (image_id == 1024) {
                   
        } else if (image_id == 1026) {
            
        } else if (image_id == 1072) {
                   
        } else if (image_id == 1069) {
            
        } else if (image_id == 1054) {
                   
        } else if (image_id == 1064) {
                   
        } else if (image_id == 1039) {
            
        } else if (image_id == 1044) {
                   
        } else if (image_id == 1057) {
            
        } else if (image_id == 1058) {
                   
        } else if (image_id == 1088) {
            
        } else if (image_id == 1006) {
     
            YLPascalString *alphaNames = [YLFileProcess getPascalStringFromFile:fileData index:&index lengthBlock:nil encode:NSUTF8StringEncoding];
            
            NSLog(@"Names of the alpha channels is %@", alphaNames.text);

        } else {
            NSLog(@"~~~~~~~~~%d",image_id);
        }
    }
    
    index = irTempIndex + sizeof(imgResSize) + imageResSize;
    
    _blockInfo.endIndex = index;
    self.endIndex = index;
    return YES;
}

static BOOL showContent = NO;

#pragma mark ---- xml parser delegate

//解析器，从两个结点之间读取内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (showContent) {
//        NSLog(@"layer content is %@",string);
    }
}

//获得结点结尾的值
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//    NSLog(@"end element is %@",elementName);
    if([elementName isEqualToString:@"photoshop:LayerName"] || [elementName isEqualToString:@"photoshop:LayerText"]) {
        showContent = NO;
    }
}

//获得结点头的值
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
//    NSLog(@"element name is %@",elementName);
    if([elementName isEqualToString:@"photoshop:LayerName"] || [elementName isEqualToString:@"photoshop:LayerText"]) {
        showContent = YES;
    }
}


@end
