//
//  SharedViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 2/24/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit

class SharedViewController: UIViewController {


    func alertError(message: String, viewController: UIViewController) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: .None, message:
                message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            viewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    func calculateColor(value: Int) -> UIColor{
        
        if value >= 5 {
            print("value: \(value)")
            let ratingPercent = ((100 - (Double(Double(value)/10.0) * 100)) * 0.01) * 255 * 2
            print ("rating percent: \(ratingPercent)")
            let color = UIColor(red: CGFloat(ratingPercent/255), green: 1, blue: 0, alpha: 1)
            return color
        } else {
            let ratingPercent = (Double(value)/10.0)
            let color = UIColor(red: 1, green: CGFloat(ratingPercent*255)/255, blue: 0, alpha: 1)
            return color
        }
    }

}
