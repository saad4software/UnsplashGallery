//
//  DetailsViewController.swift
//  UnsplashGallery
//
//  Created by Saad on 8/4/21.
//

import UIKit

class DetailsViewController: AbstractViewController {

    @IBOutlet weak var imgMain: ZoomableImageView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    var item:PhotoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(title: item?.altDescription)
        imgMain.imageView.loadImage(imageUrl: item?.urls?.full)
        
        if let item = self.item {
            btnSave.isEnabled = !Defaults[.photoesList].contains(item)
        }

    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        if let item = self.item, !Defaults[.photoesList].contains(item) {
            Defaults[.photoesList].append(item)
            self.toast("Image saved successfully")
        } else {
            self.toast("Image already saved")
        }
    }
    
    


}
