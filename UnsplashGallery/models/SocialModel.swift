//
//  SocialModel.swift
//  UnsplashGallery
//
//  Created by Saad on 7/1/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class SocialModel : NSObject, Mappable{

    var instagramUsername : String?
    var portfolioUrl : String?
    var twitterUsername : String?


    class func newInstance(map: Map) -> Mappable?{
        return SocialModel()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        instagramUsername <- map["instagram_username"]
        portfolioUrl <- map["portfolio_url"]
        twitterUsername <- map["twitter_username"]
        
    }
}
