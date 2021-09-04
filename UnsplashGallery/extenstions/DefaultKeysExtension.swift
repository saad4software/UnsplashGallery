//
//  DefaultKeysExtension.swift
//  UnsplashGallery
//
//  Created by Saad on 2/20/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
extension DefaultsKeys {
    
    static let language = DefaultsKey<String>("language",defaultValue: "en")

    static let photoesList = DefaultsKey<[PhotoModel]>("photoesList",defaultValue: [])
}
