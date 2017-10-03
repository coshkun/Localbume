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
        return UIImage()
    }

}
