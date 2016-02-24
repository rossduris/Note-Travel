//
//  PlaceCell.swift
//  Note Travel
//
//  Created by Ross Duris on 2/23/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {
    
    @IBOutlet weak var colorTab:UIView!
    @IBOutlet weak var ratingLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
