//
//  SearchRequest.swift
//  UnsplashGallery
//
//  Created by Saad on 7/1/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class SearchRequest : NSObject, Mappable{

    var query : String?
    var page : Int?
    var per_page : Int?
    var order_by : String?
    var collections : String?
    var content_filter : String?
    var color : String?
    var orientation : String?

    public init(query : String?, page : Int?, per_page : Int?, order_by : String?, collections : String?, content_filter : String?, color : String?, orientation : String?) {
        self.query  = query
        self.page  = page
        self.per_page  = per_page
        self.order_by  = order_by
        self.collections  = collections
        self.content_filter  = content_filter
        self.color  = color 
        self.orientation  = orientation
    }


    class func newInstance(map: Map) -> Mappable?{
        return SearchRequest()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        query <- map["query"]
        page <- map["page"]
        per_page <- map["per_page"]
        order_by <- map["order_by"]
        collections <- map["collections"]
        content_filter <- map["content_filter"]
        color <- map["color"]
        orientation <- map["orientation"]

    }


}
