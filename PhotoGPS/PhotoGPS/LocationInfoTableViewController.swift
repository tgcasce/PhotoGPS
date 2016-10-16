//
//  LocationInfoTableViewController.swift
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/4.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

import UIKit
import Photos

class LocationInfoTableViewController: UITableViewController {

    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var altitudeTextField: UITextField!
    @IBOutlet weak var speedTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: IBAction
    
    @IBAction func confirmModify(_ sender: UIButton) {
        
        guard let latitude = self.latitudeTextField.text else {
            return
        }
        guard let longitude = self.longitudeTextField.text else {
            return
        }
        guard let altitude = self.altitudeTextField.text else {
            return
        }
        guard let speed = self.speedTextField.text else {
            return
        }

        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        let gpsInfoGenerator = TGCGPSInfoGenerator.configGenerator(withLatitude: latitude, longitude: longitude, altitude: altitude, speed: speed)
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
    
    @IBAction func giveUp(_ sender: UIButton) {
        (self.presentingViewController as! ViewController).originalImage = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension LocationInfoTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacter = CharacterSet(charactersIn: "-1234567890.").inverted
        let filterdString = string.components(separatedBy: allowedCharacter).joined(separator: "")
        return filterdString == string
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            self.longitudeTextField.becomeFirstResponder()
        } else if textField.tag == 2 {
            self.altitudeTextField.becomeFirstResponder()
        } else if textField.tag == 3 {
            self.speedTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
