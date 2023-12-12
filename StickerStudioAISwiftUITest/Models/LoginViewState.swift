//
//  LoginViewState.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 10.12.2023.
//

import Foundation

class Authorization: ObservableObject {
    @Published var isAuthorized: Bool = {
        UserDefaults.standard.string(forKey: "uid") != nil
    }()
}
