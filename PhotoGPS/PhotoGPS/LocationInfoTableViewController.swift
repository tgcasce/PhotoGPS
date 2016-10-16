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
    
    @IBAction func confirmModify(sender: UIButton) {
        
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
        self.view.userInteractionEnabled = false
        let gpsInfoGenerator = TGCGPSInfoGenerator.configGeneratorWithLatitude(latitude, longitude: longitude, altitude: altitude, speed: speed)
        let success = gpsInfoGenerator.saveGPSImageWithoutGPS((self.presentingViewController as! ViewController).originalImage!)
        if success {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                
                let _ = PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(NSURL(string: tempImagePath)!)
                }, completionHandler: { (success, error) -> Void in
                    self.view.userInteractionEnabled = true
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        if success {
                            self.presentViewController(TGCAlertController.alertControllerWith("修改成功", message: nil, handler: { (alertAction) -> Void in
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }), animated: true, completion: nil)
                        } else {
                            self.presentViewController(TGCAlertController.alertControllerWith("请重新尝试", message: nil, handler: nil), animated: true, completion: nil)
                        }
                    })
            })
        } else {
            self.view.userInteractionEnabled = true
            self.presentViewController(TGCAlertController.alertControllerWith("请重新尝试", message: nil, handler: nil), animated: true, completion: nil)
        }
    }
    
    @IBAction func giveUp(sender: UIButton) {
        (self.presentingViewController as! ViewController).originalImage = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension LocationInfoTableViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacter = NSCharacterSet(charactersInString: "-1234567890.").invertedSet
        let filterdString = string.componentsSeparatedByCharactersInSet(allowedCharacter).joinWithSeparator("")
        return filterdString == string
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
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
