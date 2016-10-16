//
//  TGCAlertController.swift
//  PhotoGPS
//
//  Created by DonMaulyn on 15/12/5.
//  Copyright © 2015年 DonMaulyn. All rights reserved.
//

import UIKit

class TGCAlertController: NSObject {
    
    class func alertControllerWith(_ title: String?, message: String?, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "好的", style: .cancel, handler: handler))
        return alertController
    }
    
    
}
