//
//  PhotoModel.swift
//  UnsplashGallery
//
//  Created by Saad on 7/1/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import ObjectMapper


class PhotoModel :Mappable, DefaultsSerializable {
    
    var altDescription : String?
    var blurHash : String?
    var categories : [AnyObject]?
    var color : String?
    var createdAt : String?
    var currentUserCollections : [AnyObject]?
    var descriptionField : String?
    var height : Int?
    var id : String?
    var likedByUser : Bool?
    var likes : Int?
    var links : LinkModel?
    var promotedAt : String?
    var sponsorship : AnyObject?
    var updatedAt : String?
    var urls : UrlModel?
    var user : UserModel?
    var width : Int?
    
    var isDeleted: Bool?

    
    public init(url:String?, description:String?, height:Int?, width:Int?) {
        self.altDescription = description
        self.urls = UrlModel(url: url)
        self.height = height
        self.width = width
        
    }

    required init?(map: Map){}

    func mapping(map: Map)
    {
        altDescription <- map["alt_description"]
        blurHash <- map["blur_hash"]
        categories <- map["categories"]
        color <- map["color"]
        createdAt <- map["created_at"]
        currentUserCollections <- map["current_user_collections"]
        descriptionField <- map["description"]
        height <- map["height"]
        id <- map["id"]
        likedByUser <- map["liked_by_user"]
        likes <- map["likes"]
        links <- map["links"]
        promotedAt <- map["promoted_at"]
        sponsorship <- map["sponsorship"]
        updatedAt <- map["updated_at"]
        urls <- map["urls"]
        user <- map["user"]
        width <- map["width"]
        
        isDeleted <- map["isDeleted"]
    }


}

extension PhotoModel:Equatable {
    static func == (lhs: PhotoModel, rhs: PhotoModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
