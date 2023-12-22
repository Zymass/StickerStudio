//
//  StickersError.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 19.12.2023.
//

import Foundation

enum StickersError: Error {
    case fileIsEmpty
    case fileTooBig
    case invalidDimensions
    case countLimitExceeded
    case dataTypeMismatch
    case setIsEmpty
    case emojiIsEmpty
    case telegramNotInstalled
}
