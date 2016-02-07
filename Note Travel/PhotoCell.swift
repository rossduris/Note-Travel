//
//  PhotoCell.swift
//  Note Travel
//
//  Created by Ross Duris on 2/5/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photo: UIImageView {
        set {
            self.photoView = newValue
        }
        
        get {
            return self.photoView
        }
    }
    
}
