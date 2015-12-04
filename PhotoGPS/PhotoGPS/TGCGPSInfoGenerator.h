//
//  TGCGPSInfoGenerator.h
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/1.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TGCGPSInfoGenerator : NSObject


+ (instancetype)configGeneratorWithImageData:(NSData *)imageData;

- (UIImage *)GPSImageWithoutGPS:(NSData *)image;
- (BOOL)saveGPSImageWithoutGPS:(NSData *)image;
@end
