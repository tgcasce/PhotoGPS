//
//  TGCGPSInfoGenerator.h
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/1.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TGCGPSInfoGenerator : NSObject

@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *altitude;
@property (nonatomic, copy) NSString *speed;

+ (instancetype)configGeneratorWithLatitude:(NSString *)latitude longitude:(NSString *)longitude altitude:(NSString *)altitude speed:(NSString *)speed;
+ (instancetype)configGeneratorWithLocation:(CLLocation *)location;

//- (UIImage *)GPSImageWithoutGPS:(NSData *)image;
- (BOOL)saveGPSImageWithoutGPS:(UIImage *)image;
- (void)printImageMeataData:(NSData *)data;
@end
