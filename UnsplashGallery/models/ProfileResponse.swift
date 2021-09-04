//
//  ProfileResponse.swift
//  UnsplashGallery
//
//  Created by Saad on 7/1/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class ProfileResponse : NSObject, Mappable{

    var bio : String?
    var downloads : Int?
    var email : String?
    var firstName : String?
    var followedByUser : Bool?
    var id : String?
    var instagramUsername : String?
    var lastName : String?
    var links : LinkModel?
    var location : String?
    var portfolioUrl : AnyObject?
    var totalCollections : Int?
    var totalLikes : Int?
    var totalPhotos : Int?
    var twitterUsername : String?
    var updatedAt : String?
    var uploadsRemaining : Int?
    var username : String?


    class func newInstance(map: Map) -> Mappable?{
        return ProfileResponse()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        bio <- map["bio"]
        downloads <- map["downloads"]
        email <- map["email"]
        firstName <- map["first_name"]
        followedByUser <- map["followed_by_user"]
        id <- map["id"]
        instagramUsername <- map["instagram_username"]
        lastName <- map["last_name"]
        links <- map["links"]
        location <- map["location"]
        portfolioUrl <- map["portfolio_url"]
        totalCollections <- map["total_collections"]
        totalLikes <- map["total_likes"]
        totalPhotos <- map["total_photos"]
        twitterUsername <- map["twitter_username"]
        updatedAt <- map["updated_at"]
        uploadsRemaining <- map["uploads_remaining"]
        username <- map["username"]
        
    }


}
