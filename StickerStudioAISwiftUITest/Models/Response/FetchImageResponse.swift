//
//  FetchImageResponse.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.12.2023.
//

import Foundation

struct FetchImageResponse: Codable {
    let status: String
    let id: Int
    let tip: String
    let output: [String]
}
