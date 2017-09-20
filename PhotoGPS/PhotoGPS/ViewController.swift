//
//  ViewController.swift
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/1.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    let photoController = UIImagePickerController()
    let actionController = UIAlertController(title: "请选择一种输入GPS信息的方式", message: nil, preferredStyle: .actionSheet)
    var originalImage: UIImage?
    var gpsGenerator: TGCGPSInfoGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureActionController()
        configureMotionEffects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func image(image: UIImage!, didFinishSavingWithError: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
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
//    }
    
    fileprivate func configureActionController() {
        let wayOne = UIAlertAction(title: "通过经纬度坐标指定", style: .default) { (alertAction) -> Void in
            
            let locationInfoTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationInfoTableViewController")
            self.present(locationInfoTableViewController, animated: true, completion: nil)
        }
        let wayTwo = UIAlertAction(title: "通过地名查找", style: .default) { (alertAction) -> Void in
            
            let locationInfoTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FindPlaceMarkViewController")
            self.present(locationInfoTableViewController, animated: true, completion: nil)
        }
        let wayThree = UIAlertAction(title: "在地图中选点", style: .default) { (alertAction) -> Void in
            
            let locationInfoTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapLocationViewController")
            self.present(locationInfoTableViewController, animated: true, completion: nil)
        }
        self.actionController.addAction(wayOne)
        self.actionController.addAction(wayTwo)
        self.actionController.addAction(wayThree)
    }
    
    fileprivate func configureMotionEffects() {
        let horizontalEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = -50.0
        horizontalEffect.maximumRelativeValue = 50.0
        let verticalEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = -50.0
        verticalEffect.maximumRelativeValue = 50.0
        self.backgroundImageView.addMotionEffect(horizontalEffect)
        self.backgroundImageView.addMotionEffect(verticalEffect)
    }
    
    fileprivate func configurePhotoController(_ isTakePhoto: Bool) {
        self.photoController.delegate = self
        if isTakePhoto {
            self.photoController.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            self.photoController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        self.present(self.photoController, animated: true) { () -> Void in
            
        }
    }
    
    
//MARK: for future use
/*
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
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                
                let request = PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(NSURL(string: documentDirectory + "/GPS.jpg")!)
                
                request?.favorite = true
                }) { (success, error) -> Void in
                    NSLog("Finished updating asset. %@", (success ? "Success." : error!))
            }
        })
    }
    
    func saveToDocumentsWithDataTo(asset: PHAsset, options: PHImageRequestOptions) {
        
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: options, resultHandler: { (dataToSave, string, orientation, info) -> Void in
            self.gpsGenerator!.saveGPSImageWithoutGPS(UIImage(data: dataToSave!))
        })
    }
    
    func chooseRightWay() {
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

        self.writeToSavedPhotosAlbum(asset, options: options)

        //该方法修改照片应用中的图片可以修改位置，但是实际文件似乎没有GPS信息
        self.assetChangeRequest(asset, withLocation: assetToUseMetaData.location)

        self.creationRequestFor(assetToUseMetaData, withLocation: assetToUseMetaData.location, options: options)

        //该方法将图片存到应用Documents文件夹中，并且图片带有GPS元数据
        self.saveToDocumentsWithDataTo(asset, options: options)
    }
*/
    
    
    //MARK: IBAction
    
    @IBAction func pickPhotos(_ sender: UIButton) {
        configurePhotoController(false)
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        configurePhotoController(true)
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        self.originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage

        self.dismiss(animated: true) { () -> Void in
            
            self.present(self.actionController, animated: true, completion: nil)
        }
    }
    
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        
//    }
}
