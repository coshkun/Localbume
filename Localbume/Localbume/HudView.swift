//
//  HudView.swift
//  Localbume
//
//  Created by coskun on 10.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import Foundation
import UIKit

class HudView: UIView {
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hv = HudView(frame: view.frame)
        hv.opaque = false
        
        view.addSubview(hv)
        view.userInteractionEnabled = false
        
        // debug
        // hv.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        
        hv.show(animated)
        return hv
    }
    
    override func drawRect(rect: CGRect) {
        let boxWidth : CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth, height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        //Load the Hud Img
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.drawAtPoint(imagePoint)
        }
        //Draw text by hand-made
        let attribs = [NSFontAttributeName: UIFont.systemFontOfSize(16),
            NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let nstxt = NSString(string: text)
        let txtSize = nstxt.sizeWithAttributes(attribs)
        let txtPoit = CGPoint(
            x: center.x - round(txtSize.width / 2 ),
            y: center.y - round(txtSize.height / 2) + boxHeight / 4)
        
        nstxt.drawAtPoint(txtPoit, withAttributes: attribs)
    }
    
    func show(animated: Bool){
        if animated {
            //1
            alpha = 0
            // let x = bounds.size.width
            // let y = bounds.size.height
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            //2
            /* UIView.animateWithDuration(0.3, animations: {
                //3
                self.alpha = 1
                self.transform = CGAffineTransformIdentity
            }) */
            UIView.animateWithDuration(0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                    self.alpha = 1
                    self.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
    
    
}





