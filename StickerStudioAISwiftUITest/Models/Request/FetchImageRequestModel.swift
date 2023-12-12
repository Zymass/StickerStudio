//
//  FetchImageRequestModel.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 03.12.2023.
//

import Foundation

struct FetchImageRequestModel: Encodable {
    let key: String
    let requestId: Int

    enum CodingKeys: String, CodingKey {
        case key
        case requestId = "request_id"
    }
}
