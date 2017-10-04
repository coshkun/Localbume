//
//  LocationCell.swift
//  Localbume
//
//  Created by coskun on 16.09.2017.
//  Copyright © 2017 coskun. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor(white: 22/255.0, alpha: 1.0)
        descriptionLabel.textColor = UIColor.whiteColor()
        //descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        //addressLabel.highlightedTextColor = addressLabel.textColor
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        //Round Images
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(location: Location){
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let pmark = location.placemark {
            //addressLabel.text = stringToSingleLine(from: pmark)
            var text = ""
            text.add(pmark.subThoroughfare)
            text.add(pmark.thoroughfare, separatedBy: " ")
            text.add(pmark.locality, separatedBy: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = stringFromPosition(location.latitude, long: location.longitude)
        }
        
        photoImageView.image = thumbnailFor(location)
    }
    
    func thumbnailFor(location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImage(withBounds: CGSize(width: 52, height: 52))
        }
        return UIImage(named: "No Photo")!
    }

}
