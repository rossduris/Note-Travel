//
//  EntryCell.swift
//  Note Travel
//
//  Created by Ross Duris on 2/10/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit

class EntryCell: UITableViewCell {
    
    @IBOutlet weak var entryTitleLabel:UILabel!
    @IBOutlet weak var entryPhotoView:UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        entryPhotoView.layer.borderWidth = 1
        entryPhotoView.layer.masksToBounds = false
        entryPhotoView.layer.borderColor = UIColor.grayColor().CGColor
        entryPhotoView.layer.cornerRadius = entryPhotoView.frame.height/2
        entryPhotoView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
