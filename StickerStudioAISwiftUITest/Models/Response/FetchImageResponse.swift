//
//  FetchImageResponse.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.12.2023.
//

import Foundation

struct FetchImageResponse: Codable {
    let result: String?
    let responseData: FetchImageData?
}

struct FetchImageData: Codable {
    let status: String?
    let id: Int?
    let messege: String?
    let tip: String?
    let output: [String]?
}
