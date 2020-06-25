//
//  Model.swift
//  11health Code Challenge
//
//  Created by dustin on 24/6/2020.
//  Copyright © 2020 Jan. All rights reserved.
//

import Foundation
struct GeoObject:Decodable{
    var zip_code:String
    var lat:Double
    var lng:Double
    var timezone: Timezone
    var acceptable_city_names : [Acceptable_city_names]?
    var area_codes : [Int]?
    }

struct Timezone:Decodable{
    var timezone_identifier:String
    var timezone_abbr:String
    var utc_offset_sec:Double
    var is_dst: String
}
struct Acceptable_city_names:Decodable{
    var city:String
    var state:String
}
enum GeoServiceError:Error{
    case resultFromZipIsInvalid
    case jSONInfoNotComplete
}
