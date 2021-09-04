//
//  UrlModel.swift
//  UnsplashGallery
//
//  Created by Saad on 7/1/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class UrlModel : NSObject, Mappable{

    var full : String?
    var raw : String?
    var regular : String?
    var small : String?
    var thumb : String?


    class func newInstance(map: Map) -> Mappable?{
        return UrlModel()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        full <- map["full"]
        raw <- map["raw"]
        regular <- map["regular"]
        small <- map["small"]
        thumb <- map["thumb"]
        
    }
    
    init(url:String?){
        self.raw = url
        self.full = url
        self.thumb = url
    }

}
