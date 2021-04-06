//
//  APIProviderProtocol.swift
//  PaginationTest
//
//  Created by Mikhail Plotnikov on 06.04.2021.
//
import RxSwift
import Foundation

protocol APIProviderProtocol {
    func getCharacters(limit: Int, offset: Int) -> Observable<MarvelModel>
}
