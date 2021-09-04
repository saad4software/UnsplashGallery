//
//  NoResultsCollectionViewCell.swift
//  UnsplashGallery
//
//  Created by Saad on 2/19/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import UIKit

class NoResultsCollectionViewCell: UICollectionViewCell {

    var addImageAction:((NoResultsCollectionViewCell)->())?
    @IBAction func btnAddImageAction(_ sender: Any) {
        addImageAction?(self)
    }
    

}
