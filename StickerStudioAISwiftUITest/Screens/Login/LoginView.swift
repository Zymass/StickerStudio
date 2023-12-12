//
//  LoginView.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 08.10.2023.
//

import SwiftUI

struct LoginView: View {

    @State private var activeIntro: PageIntro = pageIntros[0]
    @State private var keyboardHeight: CGFloat = 0
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        GeometryReader {
            let size = $0.size

            IntroView(intro: $activeIntro, size: size, viewModel: _viewModel)
        }
        .padding(15)
        /// Manual Keyboard Push
        .offset(y: -keyboardHeight)
        /// Disabling Native Keyboard Push
        .ignoresSafeArea(.keyboard, edges: .all)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { output in
            if let info = output.userInfo, let height = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
                keyboardHeight = height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: keyboardHeight)
    }
}

//#Preview {
//    @EnvironmentObject var authorization = Authorization()
//    let viewModel = LoginViewModel(authorization: _authorization)
//    return LoginView(viewModel: viewModel)
//}
