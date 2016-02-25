//
//  RatingSlider.swift
//  Note Travel
//
//  Created by Ross Duris on 2/23/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit

class RatingSlider: UIControl {
    
    @IBOutlet weak var sliderTab: UIView!
    @IBOutlet weak var ratingNumberLabel: UILabel!
    @IBOutlet weak var sliderBarImage: UIImageView!
    @IBOutlet weak var sliderOutline: UIImageView!
    var ratingNumber = 0
    

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print(touch.locationInView(touch.view))
        
        let barWidth = self.frame.width
        let halfOfSlider = sliderTab.frame.width/2
        print(barWidth)
        let touchX = touch.locationInView(touch.view).x
        if touchX < barWidth - halfOfSlider && touchX > 0 + halfOfSlider{
            sliderTab.frame.origin.x = touch.locationInView(touch.view).x - halfOfSlider
        }
        
        var ratingPercent = NSNumber()
        
        if touchX  > barWidth/2 {
            ratingPercent = round((sliderTab.frame.origin.x/(barWidth-sliderTab.frame.width))*100)
            print(ratingPercent)
            
            let value = ((Double(100 - Int(ratingPercent)) * 0.01)*255 * 1.9) + Double(halfOfSlider)
            print(value)
    
            let activeColor = UIColor(red: CGFloat(round(value))/255, green: 1, blue: 0, alpha: 1)

            sliderBarImage.tintColor = activeColor
            sliderOutline.tintColor = activeColor
            ratingNumberLabel.textColor = activeColor
            
        } else {
            ratingPercent = round((sliderTab.frame.origin.x/barWidth)*130)
            print(ratingPercent)
            let value = ((Double(ratingPercent) * 0.01)*255 * 2)
            print(value)    
            let activeColor = UIColor(red: 1, green: CGFloat(round(value))/255, blue: 0, alpha: 1)
            
            sliderBarImage.tintColor = activeColor
            sliderOutline.tintColor = activeColor
            ratingNumberLabel.textColor = activeColor
     
        }
        
        let rating = Int(ratingPercent)

        switch rating {
        case 0..<15:
            ratingNumber = 1
            ratingNumberLabel.text = "1/10"
        case 15..<25:
            ratingNumber = 2
            ratingNumberLabel.text = "2/10"
        case 25..<35:
            ratingNumber = 3
            ratingNumberLabel.text = "3/10"
        case 35..<45:
            ratingNumber = 4
            ratingNumberLabel.text = "4/10"
        case 45..<55:
            ratingNumber = 5
            ratingNumberLabel.text = "5/10"
        case 55..<65:
            ratingNumber = 6
            ratingNumberLabel.text = "6/10"
        case 65..<75:
            ratingNumber = 7
            ratingNumberLabel.text = "7/10"
        case 75..<85:
            ratingNumber = 8
            ratingNumberLabel.text = "8/10"
        case 85..<95:
            ratingNumber = 9
            ratingNumberLabel.text = "9/10"
        case 95..<115:
            ratingNumber = 10
            ratingNumberLabel.text = "10/10"
        default:
            print("Not in range")
        }
        
   
        return true
    }    
   
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        true
    }

    override func layoutSubviews() {
        
        sliderBarImage.image = sliderBarImage.image?.imageWithRenderingMode(.AlwaysTemplate)
        sliderOutline.image = sliderOutline.image?.imageWithRenderingMode(.AlwaysTemplate)
        let middleColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
        sliderBarImage.tintColor = middleColor
        sliderOutline.tintColor = middleColor
        ratingNumberLabel.textColor = middleColor
    }
    

}
