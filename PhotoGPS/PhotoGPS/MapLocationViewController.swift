//
//  MapLocationViewController.swift
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/5.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

import UIKit
import MapKit
import Photos

class MapLocationViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var mapLocation: CLLocation?
    var mapAnnotation: TGCAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPreviousSelect(_ sender: UITapGestureRecognizer) {
        self.confirmButton.isEnabled = false
        self.mapLocation = nil
        if self.mapAnnotation != nil {
            self.mapView.removeAnnotation(self.mapAnnotation!)
            self.mapAnnotation = nil
        }
    }
    
    @IBAction func selectPlace(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if self.mapAnnotation != nil {
                self.mapView.removeAnnotation(self.mapAnnotation!)
                self.mapAnnotation = nil
            }
            let point = sender.location(in: self.mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: self.mapView)
            self.mapLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.mapAnnotation = TGCAnnotation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.mapView.addAnnotation(self.mapAnnotation!)
        } else if sender.state == .ended {
            self.confirmButton.isEnabled = true
        }
    }

    @IBAction func confirmPlace(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        let gpsInfoGenerator = TGCGPSInfoGenerator.configGenerator(with: self.mapLocation)
        let success = gpsInfoGenerator?.saveGPSImageWithoutGPS((self.presentingViewController as! ViewController).originalImage!)
        if success! {
            PHPhotoLibrary.shared().performChanges({ () -> Void in
                
                let _ = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(string: tempImagePath)!)
                }, completionHandler: { (success, error) -> Void in
                    
                    OperationQueue.main.addOperation({ () -> Void in
                        self.view.isUserInteractionEnabled = true
                        if success {
                            self.present(TGCAlertController.alertControllerWith("修改成功", message: nil, handler: { (alertAction) -> Void in
                                self.dismiss(animated: true, completion: nil)
                            }), animated: true, completion: nil)
                        } else {
                            self.present(TGCAlertController.alertControllerWith("请重新尝试", message: nil, handler: nil), animated: true, completion: nil)
                        }
                    })
            })
        } else {
            self.view.isUserInteractionEnabled = true
            self.present(TGCAlertController.alertControllerWith("请重新尝试", message: nil, handler: nil), animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelModify(_ sender: UIButton) {
        (self.presentingViewController as! ViewController).originalImage = nil
        self.dismiss(animated: true, completion: nil)
    }

}

class TGCAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
