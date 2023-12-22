//
//  LottieView.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 17.12.2023.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(animationView)
        NSLayoutConstraint.activate ([
            animationView.heightAnchor.constraint(equalTo: uiView.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: uiView.widthAnchor)
        ])

        DotLottieFile.loadedFrom(url: url) { result in
            switch result {
            case .success(let response):
                animationView.loadAnimation(from: response)
                animationView.loopMode = .loop
                animationView.play()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
