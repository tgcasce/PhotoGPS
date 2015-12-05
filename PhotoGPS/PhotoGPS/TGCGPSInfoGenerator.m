//
//  TGCGPSInfoGenerator.m
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/1.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

#import "TGCGPSInfoGenerator.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define GPSVersion @"2.3.0.0"

@implementation TGCGPSInfoGenerator

+ (instancetype)configGeneratorWithLatitude:(NSString *)latitude longitude:(NSString *)longitude altitude:(NSString *)altitude speed:(NSString *)speed; {
    TGCGPSInfoGenerator *generator = [[[self class] alloc] init];

    if ([latitude hasPrefix:@"-"]) {
        NSMutableString *rightLatitude = [NSMutableString stringWithString:[generator rightFormat:fabs([latitude doubleValue])]];
        [rightLatitude appendString:@"S"];
        generator.latitude = rightLatitude;
    } else {
        generator.latitude = latitude;
    }
    
    if ([longitude hasPrefix:@"-"]) {
        NSMutableString *rightLongitude = [NSMutableString stringWithString:[generator rightFormat:fabs([longitude doubleValue])]];
        [rightLongitude appendString:@"W"];
        generator.longitude = rightLongitude;
    } else {
        generator.longitude = longitude;
    }
    generator.altitude = altitude;
    generator.speed = speed;
    return generator;
}

+ (instancetype)configGeneratorWithLocation:(CLLocation *)location {
    TGCGPSInfoGenerator *generator = [[[self class] alloc] init];
    generator.latitude = [generator rightStringForLatitude:location.coordinate.latitude];
    generator.longitude = [generator rightStringForLongitude:location.coordinate.longitude];
    generator.altitude = [NSString stringWithFormat:@"%f", location.altitude];
    generator.speed = [NSString stringWithFormat:@"%f", location.speed];
    return generator;
}

#pragma mark -

- (NSString *)rightStringForLatitude:(CLLocationDegrees)latitude {
    if (latitude >= 0) {
        return [NSString stringWithFormat:@"%fN", latitude];
    } else {
        return [NSString stringWithFormat:@"%@S", [self rightFormat:fabs(latitude)]];
    }
}

- (NSString *)rightStringForLongitude:(CLLocationDegrees)longitude {
    if (longitude >= 0) {
        return [NSString stringWithFormat:@"%fE", longitude];
    } else {
        return [NSString stringWithFormat:@"%@W", [self rightFormat:fabs(longitude)]];
    }
}

- (NSString *)rightFormat:(CLLocationDegrees)degrees {
    NSInteger interger = (NSInteger)degrees;
    CGFloat minute = (degrees - interger) * 60;
    return [NSString stringWithFormat:@"%lu,%f", (long)interger, minute];
}

//- (UIImage *)GPSImageWithoutGPS:(NSData *)image {
//    
//    CFMutableDataRef imageData = CFDataCreateMutable(kCFAllocatorDefault, 0);
//    
//    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.imageData, NULL);
//    CGImageMetadataRef metadataRef = CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL);
//    
//    CGImageDestinationRef imageDest = CGImageDestinationCreateWithData(imageData, kUTTypeJPEG, 1, NULL);
//    CGMutableImageMetadataRef imageMetadata = CGImageMetadataCreateMutableCopy(metadataRef);
//    CFRelease(imageSource);
//    
//    NSDictionary *options = @{(__bridge id)kCGImageDestinationMergeMetadata: @YES};
//    CGImageDestinationAddImageAndMetadata(imageDest, [[UIImage alloc] initWithData:image].CGImage, metadataRef, (__bridge CFDictionaryRef)options);
//    CGImageDestinationFinalize(imageDest);
//    CFRelease(imageMetadata);
//    CFRelease(metadataRef);
//    CFRelease(imageDest);
//    
//    NSData *data = CFBridgingRelease(imageData);
//    return [[UIImage alloc] initWithData:data];
//}

- (void)printImageMeataData:(NSData *)data {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    CGImageMetadataRef metadataRef = CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL);
    CFArrayRef array = CGImageMetadataCopyTags(metadataRef);
    for (id tag in (__bridge id)array) {
        NSLog(@"%@", tag);
    }
    CFRelease(array);
    CFRelease(metadataRef);
    CFRelease(imageSource);
}

- (BOOL)saveGPSImageWithoutGPS:(UIImage *)image {
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)UIImageJPEGRepresentation(image, 1.0), NULL);
//    CFDictionaryRef propertyRef = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
//    CFDictionaryRef GPSMetadataRef = CFDictionaryGetValue(propertyRef, kCGImagePropertyGPSDictionary);
    CGImageMetadataRef metadataRef = CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL);
    
    NSString *filePath = [NSString stringWithFormat:@"%@/tmpGPSImage.jpg", NSTemporaryDirectory()];
    CFURLRef imageURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)filePath, 0, 0);
    CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL(imageURL, kUTTypeJPEG, 1, NULL);
    CGMutableImageMetadataRef imageMetadata = CGImageMetadataCreateMutableCopy(metadataRef);
//    CFRelease(GPSMetadataRef);
//    CFRelease(propertyRef);
    
    NSString *exifGPSSpeed = @"exif:GPSSpeed";
    NSString *exifGPSSpeedRef = @"exif:GPSSpeedRef";
    NSString *exifGPSVersionID = @"exif:GPSVersionID";
    NSString *exifGPSDirectionRef = @"exif:GPSDirectionRef";
    NSString *exifGPSLatitude = @"exif:GPSLatitude";
    NSString *exifGPSLongitude = @"exif:GPSLongitude";
    NSString *exifGPSAltitude = @"exif:GPSAltitude";
    
    //string format
//    NSString *latitude = @"31,52.5924S";
//    NSString *longitude = @"43,13.998W";
    
    CGImageMetadataSetValueWithPath(imageMetadata, NULL, (__bridge CFStringRef)exifGPSSpeed, (__bridge CFStringRef)self.speed);
    CGImageMetadataSetValueWithPath(imageMetadata, NULL, (__bridge CFStringRef)exifGPSSpeedRef, (__bridge CFStringRef)@"K");
    CGImageMetadataSetValueWithPath(imageMetadata, NULL, (__bridge CFStringRef)exifGPSVersionID, (__bridge CFStringRef)GPSVersion);
    CGImageMetadataSetValueWithPath(imageMetadata, NULL, (__bridge CFStringRef)exifGPSDirectionRef, (__bridge CFStringRef)@"T");
    CGImageMetadataSetValueWithPath(imageMetadata, NULL, (__bridge CFStringRef)exifGPSLatitude, (__bridge CFStringRef)self.latitude);
    CGImageMetadataSetValueWithPath(imageMetadata, NULL, (__bridge CFStringRef)exifGPSLongitude, (__bridge CFStringRef)self.longitude);
    CGImageMetadataSetValueWithPath(imageMetadata, NULL, (__bridge CFStringRef)exifGPSAltitude, (__bridge CFStringRef)self.altitude);
    
    NSDictionary *options = @{(__bridge id)kCGImageDestinationMergeMetadata: @YES};
    CGImageDestinationAddImageAndMetadata(imageDest, image.CGImage, imageMetadata, (__bridge CFDictionaryRef)options);
    bool isSuc = CGImageDestinationFinalize(imageDest);
    CFRelease(imageSource);
    CFRelease(imageMetadata);
    CFRelease(metadataRef);
    CFRelease(imageURL);
    CFRelease(imageDest);
    
    return isSuc;
}

@end
