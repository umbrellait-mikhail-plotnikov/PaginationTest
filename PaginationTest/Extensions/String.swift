//
//  Extension.swift
//  PaginationTest
//
//  Created by Mikhail Plotnikov on 06.04.2021.
//

import Foundation
import CryptoKit

extension String {
    func md5() -> String {
        return Insecure.MD5.hash(data: self.data(using: .utf8)!).description
    }
}
