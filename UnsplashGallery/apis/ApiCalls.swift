//
//  ApiCalls.swift
//  UnsplashGallery
//
//  Created by Saad on 2/19/21.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import UIKit
import ObjectMapper

class ApiCalls {
    
    typealias onResponse<T> = (_ response : T)  -> Void
    typealias onFailure = (_ message:String) -> Void
    
    private static let instance = ApiCalls()
    public static func getInstance()->ApiCalls
    {
        return instance
    }
    
    var delegate:ApiCallsDelegate?
    var headers = [String:String]()
    
    
    func handleCallback<T>(success :@escaping onResponse<T>,failure :onFailure?,response :DataResponse<T>)
    {

        delegate?.showProgress(show: false)

        if let data = response.data {
            let json = String(data: data, encoding: String.Encoding.utf8)
            
            print("\n\n")
            print("RESPONSE \(response.request?.url ?? URL(fileURLWithPath: ""))")
            if(json!.starts(with: "{") || json!.starts(with: "["))
            {
                print(json!.data(using: .utf8)!.prettyPrintedJSONString!)

            }else
            {
                print(json!)
            }
            print("\n\n")
            
        }
        
        if let value = response.result.value
        {
            success(value)
        }
        else if let data = response.data,
                let dict = try? JSONDecoder().decode([String: [String]].self, from: data),
                dict["errors"] != nil
        {
            failure?(dict["errors"]?.first ?? "")
            delegate?.toastError(msg: dict["errors"]?.first ?? "")
        
        }
    }
    
    func handleArrayCallback<T>(success :@escaping onResponse<[T]>,failure :onFailure?,response :DataResponse<[T]>)
    {
        delegate?.showProgress(show: false)

        if let data = response.data {

            let jsonString = String(data: data, encoding: String.Encoding.utf8)
            
            print("\n\n")
            print("RESPONSE \(response.request?.url ?? URL(fileURLWithPath: ""))")
            
            if(jsonString!.starts(with: "{") || jsonString!.starts(with: "["))
            {
                print(jsonString!.data(using: .utf8)!.prettyPrintedJSONString ?? "")

            }else
            {
                print(jsonString!)
            }
            print("\n\n")
            
        }
        if let value = response.result.value
        {
            success(value)
        }
        else if let data = response.data,
                let dict = try? JSONDecoder().decode([String: [String]].self, from: data),
                dict["errors"] != nil
        {
            failure?(dict["errors"]?.first ?? "")
            delegate?.toastError(msg: dict["errors"]?.first ?? "")
        
        }
    }
            
    
    init() {
        headers["Authorization"] = "Client-ID " + Urls.accessToken

    }
    

    func importJsonArray<T: Mappable>(name:String)->[T]{
        let path = Bundle.main.path(forResource: name, ofType: "json") ?? ""
        let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
        let array = [T](JSONString: String(data: data ?? Data(), encoding: .utf8) ?? "[]")
        return array ?? [T]()

    }
    
    func importJsonModel<T: Mappable>(name:String)->T{
        let path = Bundle.main.path(forResource: name, ofType: "json") ?? ""
        let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
        let model = T(JSONString: String(data: data ?? Data(), encoding: .utf8) ?? "{}")
        return model ?? T(JSONString: "{}")!

    }
    
    ///convert json fields to 'get' url fields
    func json2Url<T:Mappable>(_ request:T, baseUrl:String)->String{
        var url = baseUrl + "?"
        let params = request.toJSON()
        for (index, value) in params.enumerated(){
            url += value.key
            url += "="
            url += String(describing: value.value)
            
            url += (index < params.count-1) ? "&":""
        }
        return url.replacingOccurrences(of: " ", with: "%20")
    }

    func getArray<R>(url:String, failure :onFailure?, success :@escaping onResponse<[R]>) where R:Mappable
    {
        print("GETARRAY \(url)")
        
        delegate?.showProgress(show: true)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseArray(completionHandler: { (response: DataResponse<[R]>) in
            self.handleArrayCallback(success: success, failure: failure, response: response)
            
        })
    }
    

    func get<R>(url:String, failure :onFailure?, success :@escaping onResponse<R>) where R:Mappable
    {
        print("GET \(url)")
        
        delegate?.showProgress(show: true)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseObject(completionHandler: { (response: DataResponse<R>) in
            self.handleCallback(success: success, failure: failure, response: response)
            
        })
    }
    
    
    func get<R,T: Mappable>(url:String ,request:T ,failure :onFailure?, success :@escaping onResponse<R>) where R:Mappable
    {
        get(url: json2Url(request,baseUrl: url), failure: failure, success: success)
    }
    
    
    func photoes(page:Int, failure :onFailure?, success :@escaping onResponse<[PhotoModel]>) {
//        let array:[PhotoModel] = importJsonArray(name: "images_list")
//        success(array)
        getArray(url: Urls.photoes + "?page=\(page)" , failure: failure, success: success)
    }
    

    
    func search(query : String?, page : Int?, per_page : Int?, order_by : String?, collections : String?, content_filter : String?, color : String?, orientation : String?, failure :onFailure?, success :@escaping onResponse<SearchResponse>) {
        let request = SearchRequest(query: query, page: page, per_page: per_page, order_by: order_by, collections: collections, content_filter: content_filter, color: color, orientation: orientation)

        get(url: Urls.search, request: request, failure: failure, success: success)
    }
}

protocol ApiCallsDelegate {
    func showProgress(show:Bool)
    func toastError(msg:String?)
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
