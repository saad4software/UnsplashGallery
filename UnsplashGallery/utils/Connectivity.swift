//
//  Connectivity.swift
//  UnsplashGallery
//
//  Created by Saad on 8/3/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import Alamofire

struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}
