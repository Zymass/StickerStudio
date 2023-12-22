//
//  AccountStickerModel.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 19.12.2023.
//

import SwiftUI

struct AccountStickerModel: Identifiable, Hashable {

    var id: String {
        return UUID().uuidString
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: AccountStickerModel, rhs: AccountStickerModel) -> Bool {
        return lhs.id == rhs.id
    }

    let image: Image
}
