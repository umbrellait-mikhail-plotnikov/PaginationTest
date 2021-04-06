//
//  MarvelModel.swift
//  PaginationTest
//
//  Created by Mikhail Plotnikov on 02.04.2021.
//

import Foundation
import ObjectMapper

struct MarvelModel: Mappable {
    init?(map: Map) {
        
    }

    mutating func mapping(map: Map) {
        results <- map["data.results"]
    }
    
    var results: [[String: Any]]?
}
