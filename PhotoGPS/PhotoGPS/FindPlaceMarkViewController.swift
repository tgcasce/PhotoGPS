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

    @IBAction func searchPlace(_ sender: UIButton) {
        self.firstSearch = false
        sender.isHidden = true
        self.placeTextField.resignFirstResponder()
        
        guard let placeString = self.placeTextField.text else {
            sender.isHidden = false
            return
        }
        guard placeString.isEmpty == false else {
            sender.isHidden = false
            return
        }
        
        self.activityIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(placeString) { (placeMarks, error) -> Void in
            
            guard let places = placeMarks else {
                self.resultPlaces = nil
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                sender.isHidden = false
                print(error?.localizedDescription)
                return
            }
            
            self.resultPlaces = places
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            sender.isHidden = false
        }
        
    }
    
    @IBAction func cancelModify(_ sender: UIButton) {
        (self.presentingViewController as! ViewController).originalImage = nil
        self.dismiss(animated: true, completion: nil)
    }
}

extension FindPlaceMarkViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.firstSearch || self.resultPlaces == nil {
            return 0
        } else {
            return self.resultPlaces!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        if let places = self.resultPlaces {
            let place = places[(indexPath as NSIndexPath).row]
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.firstSearch {
            return ""
        }
        if self.resultPlaces == nil {
            return "无结果，请更换地名查询"
        } else {
            return "请选择一个地方"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let places = self.resultPlaces {
            let place = places[(indexPath as NSIndexPath).row]
            if let location = place.location {
                self.placeTextField.resignFirstResponder()
                self.view.isUserInteractionEnabled = false
                let gpsInfoGenerator = TGCGPSInfoGenerator.configGenerator(with: location)
                let success = gpsInfoGenerator?.saveGPSImageWithoutGPS((self.presentingViewController as! ViewController).originalImage!)
                if success! {
                    PHPhotoLibrary.shared().performChanges({ () -> Void in
                        
                        let _ = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(string: tempImagePath)!)
                        }, completionHandler: { (success, error) -> Void in
                            
                            self.view.isUserInteractionEnabled = true
                            OperationQueue.main.addOperation({ () -> Void in
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
        }
    }
    
}

extension FindPlaceMarkViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
