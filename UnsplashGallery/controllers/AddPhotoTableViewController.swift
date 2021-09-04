//
//  AddPhotoTableViewController.swift
//  UnsplashGallery
//
//  Created by Saad on 8/4/21.
//

import UIKit

class AddPhotoTableViewController: UITableViewController {

    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var txtMain: UITextField!
    
    let picker = FilePicker()
    var callback:((PhotoModel)->())?
    
    var photoUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgMain.setOnClickListener { (sender) in
            self.picker.imageUrlBlock = {url in
                self.imgMain.loadImage(imageUrl: url.absoluteString)
                self.photoUrl = url.absoluteString
            }
            self.picker.showImagePicker(vc: self)
        }
    }

    @IBAction func btnAddAction(_ sender: Any) {
        guard photoUrl != "" && validateInputs(txtFields: [txtMain]) else {
            toast("Please select a photo and fill the description")
            return
        }
        let photoModel = PhotoModel(url: photoUrl, description: txtMain.text, height: Int(imgMain.image?.size.height ?? 0), width: Int(imgMain.image?.size.width ?? 0))
        callback?(photoModel)
        goBack()
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        goBack()
    }
    
}
