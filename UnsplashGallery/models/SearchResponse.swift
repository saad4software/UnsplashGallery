//
//  SearchResponse.swift
//  UnsplashGallery
//
//  Created by Saad on 7/5/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class SearchResponse : NSObject, Mappable{

    var results : [PhotoModel]?
    var total : Int?
    var totalPages : Int?


    class func newInstance(map: Map) -> Mappable?{
        return SearchResponse()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        results <- map["results"]
        total <- map["total"]
        totalPages <- map["total_pages"]
        
    }

}
