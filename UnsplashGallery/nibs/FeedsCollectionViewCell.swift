//
//  FeedsCollectionViewCell.swift
//  UnsplashGallery
//
//  Created by Saad on 2/18/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import UIKit

class FeedsCollectionViewCell: UICollectionViewCell {


    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgMain: UIImageView!
    
    
    var shareAction :((FeedsCollectionViewCell)->())?
    
    var item: PhotoModel? {
        didSet{
            
            lblTitle.text = item?.altDescription
            imgMain.loadImage(imageUrl: item?.urls?.thumb) { (img) in

            }
            print("")
        }
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
    
        shareAction?(self)
    }
    
    
    
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        let snapshot = super.snapshotView(afterScreenUpdates: afterUpdates)

        snapshot?.layer.masksToBounds = false
        snapshot?.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot?.layer.shadowRadius = 5.0
        snapshot?.layer.shadowOpacity = 0.4
        snapshot?.center = center
        return snapshot
    }

}
