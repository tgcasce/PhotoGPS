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

@interface TGCGPSInfoGenerator ()
@property (strong, nonatomic) NSData *imageData;
@end

@implementation TGCGPSInfoGenerator

+ (instancetype)configGeneratorWithImageData:(NSData *)imageData {
    TGCGPSInfoGenerator *generator = [[[self class] alloc] init];
    generator.imageData = imageData;
    return generator;
}

- (UIImage *)GPSImageWithoutGPS:(NSData *)image {
    
    CFMutableDataRef imageData = CFDataCreateMutable(kCFAllocatorDefault, 0);
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.imageData, NULL);
    CGImageMetadataRef metadataRef = CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL);
    
    CGImageDestinationRef imageDest = CGImageDestinationCreateWithData(imageData, kUTTypeJPEG, 1, NULL);
    CGMutableImageMetadataRef imageMetadata = CGImageMetadataCreateMutableCopy(metadataRef);
    CFRelease(imageSource);
    
    NSDictionary *options = @{(__bridge id)kCGImageDestinationMergeMetadata: @YES};
    CGImageDestinationAddImageAndMetadata(imageDest, [[UIImage alloc] initWithData:image].CGImage, metadataRef, (__bridge CFDictionaryRef)options);
    CGImageDestinationFinalize(imageDest);
    CFRelease(imageMetadata);
    CFRelease(metadataRef);
    CFRelease(imageDest);
    
    NSData *data = CFBridgingRelease(imageData);
    return [[UIImage alloc] initWithData:data];
}

- (BOOL)saveGPSImageWithoutGPS:(NSData *)image {
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.imageData, NULL);
    CFDictionaryRef propertyRef = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    CFDictionaryRef GPSMetadataRef = CFDictionaryGetValue(propertyRef, kCGImagePropertyGPSDictionary);
    [(__bridge NSDictionary *)GPSMetadataRef writeToFile:[NSString stringWithFormat:@"%@/GPS.plist", NSTemporaryDirectory()] atomically:YES];
    CGImageMetadataRef metadataRef = CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL);
    
    NSString *filePath = [NSString stringWithFormat:@"%@/GPS.jpg", [(NSArray<NSString *> *)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    CFURLRef imageURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)filePath, 0, 0);
    CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL(imageURL, kUTTypeJPEG, 1, NULL);
    CGMutableImageMetadataRef imageMetadata = CGImageMetadataCreateMutableCopy(metadataRef);
    CFRelease(imageSource);
    CFRelease(propertyRef);
    
    
    
    NSDictionary *options = @{(__bridge id)kCGImageDestinationMergeMetadata: @YES};
    CGImageDestinationAddImageAndMetadata(imageDest, [[UIImage alloc] initWithData:image].CGImage, metadataRef, (__bridge CFDictionaryRef)options);
    bool isSuc = CGImageDestinationFinalize(imageDest);
    CFRelease(imageMetadata);
    CFRelease(metadataRef);
    CFRelease(imageDest);
    
    return isSuc;
}

@end
