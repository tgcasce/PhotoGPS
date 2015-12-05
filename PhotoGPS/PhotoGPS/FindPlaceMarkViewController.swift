//
//  FindPlaceMarkViewController.swift
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/5.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

import UIKit
import CoreLocation
import Photos

class FindPlaceMarkViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var resultPlaces: Array<CLPlacemark>?
    var firstSearch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchPlace(sender: UIButton) {
        self.firstSearch = false
        sender.hidden = true
        self.placeTextField.resignFirstResponder()
        
        guard let placeString = self.placeTextField.text else {
            sender.hidden = false
            return
        }
        guard placeString.isEmpty == false else {
            sender.hidden = false
            return
        }
        
        self.activityIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(placeString) { (placeMarks, error) -> Void in
            
            guard let places = placeMarks else {
                self.resultPlaces = nil
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                sender.hidden = false
                print(error?.localizedDescription)
                return
            }
            
            self.resultPlaces = places
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            sender.hidden = false
        }
        
    }
    
    @IBAction func cancelModify(sender: UIButton) {
        (self.presentingViewController as! ViewController).originalImage = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FindPlaceMarkViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.firstSearch || self.resultPlaces == nil {
            return 0
        } else {
            return self.resultPlaces!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultCell", forIndexPath: indexPath)
        if let places = self.resultPlaces {
            let place = places[indexPath.row]
            cell.textLabel?.text = place.name
            var detail = ""
            if let country = place.country {
                detail += country
            }
            if let administrativeArea = place.administrativeArea {
                detail += administrativeArea
            }
            if let locality = place.locality {
                detail += locality
            }
            if let thoroughfare = place.thoroughfare {
                detail += thoroughfare
            }
            if let subThoroughfare = place.subThoroughfare {
                detail += subThoroughfare
            }
            cell.detailTextLabel?.text = detail
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.firstSearch {
            return ""
        }
        if self.resultPlaces == nil {
            return "无结果，请更换地名查询"
        } else {
            return "请选择一个地方"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let places = self.resultPlaces {
            let place = places[indexPath.row]
            if let location = place.location {
                self.view.userInteractionEnabled = false
                let gpsInfoGenerator = TGCGPSInfoGenerator.configGeneratorWithLocation(location)
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
            }
        }
        (self.presentingViewController as! ViewController).originalImage = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension FindPlaceMarkViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}