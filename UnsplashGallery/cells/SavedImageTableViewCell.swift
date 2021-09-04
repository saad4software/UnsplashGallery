//
//  SavedImageTableViewCell.swift
//  UnsplashGallery
//
//  Created by Saad on 8/4/21.
//

import UIKit

class SavedImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var lblMain: UILabel!
    
    var item:PhotoModel?{
        didSet{
            lblMain.text = item?.altDescription
            imgMain.loadImage(imageUrl: item?.urls?.thumb)
        }
    }
    
}
