//
//  ServiceSingleton.swift
//  11health Code Challenge
//
//  Created by dustin on 24/6/2020.
//  Copyright © 2020 Jan. All rights reserved.
//

import Foundation


class ServiceSingleton:NSObject{
    static let shared = ServiceSingleton()
    private override init(){
    }
    let urlStringIncomplete = "http://localhost:5000/api/timezone/"
    
    func getGeoInformation(zip:String, completionHandler:@escaping(_ storeArray:GeoObject?,_ error: GeoServiceError?)->Void){
        let urlString = urlStringIncomplete+zip
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.setValue("b064b6d2-8fbd-48b0-ac29-1a88237ce022", forHTTPHeaderField: "X-Application-Key")
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if let data = data {
               do{
                let geoObject = try JSONDecoder().decode(GeoObject.self, from: data)// decoding our data
                completionHandler(geoObject,nil)
               }catch{
                completionHandler(nil,GeoServiceError.jSONInfoNotComplete)
               }
            }else{
                completionHandler(nil,GeoServiceError.resultFromZipIsInvalid)
            }
        })
        task.resume()
    }
}
