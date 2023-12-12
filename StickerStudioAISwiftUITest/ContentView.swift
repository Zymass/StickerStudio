//
//  ContentView.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.10.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authorization: Authorization

    var body: some View {
        if authorization.isAuthorized {
            CreateStickerView()
        } else {
            let viewModel = LoginViewModel(authorization: _authorization)
            LoginView(viewModel: viewModel)
        }
    }
}
