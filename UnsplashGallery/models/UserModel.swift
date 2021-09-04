//
//  UserModel.swift
//  UnsplashGallery
//
//  Created by Saad on 7/1/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class UserModel : NSObject, Mappable{

    var acceptedTos : Bool?
    var bio : String?
    var firstName : String?
    var forHire : Bool?
    var id : String?
    var instagramUsername : String?
    var lastName : String?
    var links : LinkModel?
    var location : String?
    var name : String?
    var portfolioUrl : String?
    var profileImage : ProfileImageModel?
    var social : SocialModel?
    var totalCollections : Int?
    var totalLikes : Int?
    var totalPhotos : Int?
    var twitterUsername : String?
    var updatedAt : String?
    var username : String?


    class func newInstance(map: Map) -> Mappable?{
        return UserModel()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        acceptedTos <- map["accepted_tos"]
        bio <- map["bio"]
        firstName <- map["first_name"]
        forHire <- map["for_hire"]
        id <- map["id"]
        instagramUsername <- map["instagram_username"]
        lastName <- map["last_name"]
        links <- map["links"]
        location <- map["location"]
        name <- map["name"]
        portfolioUrl <- map["portfolio_url"]
        profileImage <- map["profile_image"]
        social <- map["social"]
        totalCollections <- map["total_collections"]
        totalLikes <- map["total_likes"]
        totalPhotos <- map["total_photos"]
        twitterUsername <- map["twitter_username"]
        updatedAt <- map["updated_at"]
        username <- map["username"]
        
    }

}
