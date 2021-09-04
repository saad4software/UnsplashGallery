//
//  LinkModel.swift
//  UnsplashGallery
//
//  Created by Saad on 7/1/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class LinkModel : NSObject, Mappable{

    var html : String?
    var likes : String?
    var photos : String?
    var portfolio : String?
    var me : String?


    class func newInstance(map: Map) -> Mappable?{
        return LinkModel()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        html <- map["html"]
        likes <- map["likes"]
        photos <- map["photos"]
        portfolio <- map["portfolio"]
        me <- map["self"]
        
    }


}
