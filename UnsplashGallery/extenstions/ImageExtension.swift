//
//  ImageExtension.swift
//  UnsplashGallery
//
//  Created by Saad on 2/13/20.
//  Copyright © 2020 Saad. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Photos

extension UIImageView
{
    
    func loadImage(imageUrl:String?)
    {

        let imgUrl = imageUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let mg = imgUrl, let url = URL(string: mg) {
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "logo1") , options: [.transition(.fade(0.2))])
        }
        else {
            self.image = #imageLiteral(resourceName: "logo3")
        }
    }
    
    func loadImage(imageUrl:String?, callback:((UIImage?)->())?)
    {
        
        let imgUrl = imageUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let mg = imgUrl, let url = URL(string: mg)
        {
            self.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "logo1"), options:[.transition(.fade(0.2))], progressBlock: .none) { (img, error, ct, url) in
                callback?(img)
            }

        }
    }
    
    func setImageColor(color: UIColor) {
      let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
      self.image = templateImage
      self.tintColor = color
    }
    
    @IBInspectable
    var imageColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!);
            return color
        }
        set {
            let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
            self.image = templateImage
            self.tintColor = newValue
            

        }
    }
    
    
}

extension UIImage {
func saveToPhotoLibrary(completion: @escaping (URL?) -> Void) {
    var localeId: String?
    PHPhotoLibrary.shared().performChanges({
        let request = PHAssetChangeRequest.creationRequestForAsset(from: self)
        localeId = request.placeholderForCreatedAsset?.localIdentifier
    }) { (isSaved, error) in
        guard isSaved else {
            debugPrint(error?.localizedDescription)
            completion(nil)
            return
        }
        guard let localeId = localeId else {
            completion(nil)
            return
        }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localeId], options: fetchOptions)
        guard let asset = result.firstObject else {
            completion(nil)
            return
        }
        getPHAssetURL(of: asset) { (phAssetUrl) in
            completion(phAssetUrl)
        }
    }
    
    func getPHAssetURL(of asset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void))
        {
                let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                    return true
                }
                asset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                    completionHandler(contentEditingInput!.fullSizeImageURL)
                })

        }
    }
}



extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}

extension String {
    func toImage () -> UIImage {
        let imageData = Data(base64Encoded: self, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
}
