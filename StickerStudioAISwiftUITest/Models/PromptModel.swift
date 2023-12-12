//
//  PromptModel.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.10.2023.
//

import Foundation

struct Prompt: Identifiable, Hashable {
    var id: UUID = .init()
    var value: String
    var isInitial: Bool = false
    var isFocused: Bool = false
}
