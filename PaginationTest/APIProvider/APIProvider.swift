//
//  APIProvider.swift
//  PaginationTest
//
//  Created by Mikhail Plotnikov on 02.04.2021.
//

import Foundation
import RxSwift
import RxAlamofire
import ObjectMapper
import CryptoKit

struct APIKey {
    let publicKey: String!
    let privateKey: String!
}

final class APIProvider: APIProviderProtocol {
    
    static let shared = APIProvider()
    
    private var keys: APIKey?
    private let marvelURL = "https://gateway.marvel.com/v1/public/characters"
    
    private func getKeys() -> APIKey {
        guard let keys = self.keys else {
//            Read from plist
            guard let path = Bundle.main.path(forResource: "keys", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path)
            else {fatalError("Need correct keys.plist")}
            
            guard let publicKey = dict["publicKey"] as? String,
                  let privateKey = dict["privateKey"] as? String
            else {fatalError("publicKey or privateKey not found")}
            
            let keys = APIKey(publicKey: publicKey, privateKey: privateKey)
            self.keys = keys
            
            return keys
        }
//        Read from param
        return keys
    }
    
    private func makeBaseURL() -> URLComponents {
        let ts = Date().timeIntervalSince1970.description
        let keys = getKeys()
        let hash = (ts + keys.privateKey + keys.publicKey).md5().dropFirst(12).description
        var marvelURLComponents = URLComponents(string: marvelURL)!
        marvelURLComponents.queryItems = [
            URLQueryItem(name: "apikey", value: keys.publicKey),
            URLQueryItem(name: "ts", value: ts),
            URLQueryItem(name: "hash", value: hash)
            ]
        return marvelURLComponents
    }
    
    public func getCharacters(limit: Int, offset: Int) -> Observable<MarvelModel> {
        
        var marvelURLComponents = makeBaseURL()
        
        marvelURLComponents.queryItems?.append(contentsOf: [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ])
        
        guard let marvelURL = try? marvelURLComponents.asURL() else { fatalError("Wrong components") }
        
        return request(.get, marvelURL)
            .debug()
            .responseJSON()
            .retry(5)
            .map {
                guard let mappedResponse = Mapper<MarvelModel>().map(JSONObject: $0.value) else { fatalError("Wrong model") }
                return mappedResponse
            }
    }
}
