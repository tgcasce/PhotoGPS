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
    
    @IBAction func cancelPreviousSelect(sender: UITapGestureRecognizer) {
        self.confirmButton.enabled = false
        self.mapLocation = nil
        if self.mapAnnotation != nil {
            self.mapView.removeAnnotation(self.mapAnnotation!)
            self.mapAnnotation = nil
        }
    }
    
    @IBAction func selectPlace(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            if self.mapAnnotation != nil {
                self.mapView.removeAnnotation(self.mapAnnotation!)
                self.mapAnnotation = nil
            }
            let point = sender.locationInView(self.mapView)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: self.mapView)
            self.mapLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.mapAnnotation = TGCAnnotation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.mapView.addAnnotation(self.mapAnnotation!)
        } else if sender.state == .Ended {
            self.confirmButton.enabled = true
        }
    }

    @IBAction func confirmPlace(sender: UIButton) {
        self.view.userInteractionEnabled = false
        let gpsInfoGenerator = TGCGPSInfoGenerator.configGeneratorWithLocation(self.mapLocation)
        let success = gpsInfoGenerator.saveGPSImageWithoutGPS((self.presentingViewController as! ViewController).originalImage!)
        if success {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                
                let _ = PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(NSURL(string: tempImagePath)!)
                }, completionHandler: { (success, error) -> Void in
                    
                    self.view.userInteractionEnabled = true
                    
            })
        } else {
            self.view.userInteractionEnabled = true
            
            return
        }
        self.cancelModify(sender)
    }
    
    @IBAction func cancelModify(sender: UIButton) {
        (self.presentingViewController as! ViewController).originalImage = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension MapLocationViewController: MKMapViewDelegate {
    
}

class TGCAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
