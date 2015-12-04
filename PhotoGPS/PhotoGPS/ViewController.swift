//
//  ViewController.swift
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/1.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    lazy var photoController = UIImagePickerController()
    var gpsGenerator: TGCGPSInfoGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func image(image: UIImage!, didFinishSavingWithError: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
//        let asset = PHAsset()
//        asset.requestContentEditingInputWithOptions(nil) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
//            //Get full image
//            let url = contentEditingInput!.fullSizeImageURL
//            let orientation = contentEditingInput!.fullSizeImageOrientation
//            let inputImage = CIImage(contentsOfURL: url!)
//            let inputImageAdj = inputImage!.imageByApplyingOrientation(orientation)
//
//            for (key, value) in inputImageAdj.properties {
//                print("key: \(key)")
//                print("value: \(value)")
//            }
//        }
    }
    
    func configurePhotoController(isTakePhoto: Bool) {
        self.photoController.delegate = self
        if isTakePhoto {
            self.photoController.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            self.photoController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        self.presentViewController(self.photoController, animated: true) { () -> Void in
            
        }
    }

    func writeToSavedPhotosAlbum(imageAsset: PHAsset, options: PHImageRequestOptions) {
        PHImageManager.defaultManager().requestImageDataForAsset(imageAsset, options: options, resultHandler: { (data, string, orientation, info) -> Void in
            let image = self.gpsGenerator?.GPSImageWithoutGPS(data!)
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        })
    }
    
    func assetChangeRequest(asset: PHAsset, withLocation location: CLLocation?) {
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            if asset.canPerformEditOperation(PHAssetEditOperation.Properties) {

                let request = PHAssetChangeRequest(forAsset: asset)
                if let newLocation = location {
                    request.location = newLocation
                }
                request.favorite = true
            }
            }) { (success, error) -> Void in
                NSLog("Finished updating asset. %@", (success ? "Success." : error!))
        }
    }
    
    func creationRequestFor(asset: PHAsset, withLocation location: CLLocation?, options: PHImageRequestOptions) {
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: options, resultHandler: { (data, string, orientation, info) -> Void in
            let image = self.gpsGenerator?.GPSImageWithoutGPS(data!)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                let request = PHAssetChangeRequest.creationRequestForAssetFromImage(image!)
                if let newLocation = location {
                    request.location = newLocation
                }
//                request.location = CLLocation(coordinate: CLLocationCoordinate2DMake(106.93126, 27.699961), altitude: 8848.0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: NSDate())
                request.favorite = true
                }) { (success, error) -> Void in
                    NSLog("Finished updating asset. %@", (success ? "Success." : error!))
            }
        })
    }
    
    func saveToDocumentsWithDataTo(asset: PHAsset, options: PHImageRequestOptions) {
        
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: options, resultHandler: { (dataToSave, string, orientation, info) -> Void in
            self.gpsGenerator!.saveGPSImageWithoutGPS(dataToSave!)
        })
    }
    
    //MARK: IBAction
    
    @IBAction func pickPhotos(sender: UIButton) {
//        configurePhotoController(false)
        
        let result: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: PHFetchOptions())
        let assetToUseMetaData = result.firstObject as! PHAsset
        let asset = result.lastObject as! PHAsset
        let options = PHImageRequestOptions()
        options.version = PHImageRequestOptionsVersion.Original
        PHImageManager.defaultManager().requestImageDataForAsset(assetToUseMetaData, options: options) { (data, string, orientation, info) -> Void in
            if self.gpsGenerator == nil {
                self.gpsGenerator = TGCGPSInfoGenerator.configGeneratorWithImageData(data!)
            }
        }
        
//        self.writeToSavedPhotosAlbum(asset, options: options)
        
        //该方法修改照片应用中的图片可以修改位置，但是实际文件似乎没有GPS信息
//        self.assetChangeRequest(asset, withLocation: assetToUseMetaData.location)
        
        self.creationRequestFor(assetToUseMetaData, withLocation: assetToUseMetaData.location, options: options)
        
        //该方法将图片存到应用Documents文件夹中，并且图片带有GPS元数据
//        self.saveToDocumentsWithDataTo(asset, options: options)
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        configurePhotoController(true)
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
//        let image = TGCGPSInfoGenerator().GPSImageWithoutGPS(info[UIImagePickerControllerOriginalImage] as! UIImage)

//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        
//    }
}