//
//  View+Keyboard.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 27.11.2023.
//

import Combine
import SwiftUI

extension View {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false })
            .eraseToAnyPublisher()
    }
}
