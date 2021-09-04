//
//  ProfileImageModel.swift
//  UnsplashGallery
//
//  Created by Saad on 7/1/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class ProfileImageModel : NSObject, Mappable{

    var large : String?
    var medium : String?
    var small : String?


    class func newInstance(map: Map) -> Mappable?{
        return ProfileImageModel()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        large <- map["large"]
        medium <- map["medium"]
        small <- map["small"]
        
    }

}
