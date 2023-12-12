//
//  CreateStickerViewModel.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.10.2023.
//

import SwiftUI
import Combine
import BackgroundRemoval
import TelegramStickersImport
import Kingfisher

enum CreateStickerViewEvents {
    case tapMainButton
    case exportToTelegram
}

final class CreateStickerViewModel: ObservableObject {
    @Published var positivePromts: [Prompt] = []
    @Published var textToImage: Image = Image("123")
    private var currentSticker: UIImage?

    let events = PassthroughSubject<CreateStickerViewEvents, Never>()
    private lazy var networkManager = NetworkManager()

    private var cancellables = Set<AnyCancellable>()

    init() {
        binding()
    }

    private func binding() {
        events
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .tapMainButton:
                    textToImageRequest()
                case .exportToTelegram:
                    guard let currentSticker else { return }

                    exportSticker(image: currentSticker)
                }
            }
            .store(in: &cancellables)
    }

    private func textToImageRequest() {
        let positivePrompts = positivePromts.map { $0.value }.joined(separator: ", ")

        networkManager.getStickerImage(prompt: positivePrompts) { [weak self] response in
            guard let self else { return }

            if let imageUrl = response?.output.first {
                removeBackground(imageUrl: imageUrl)
            } else {
                fetchImage(id: response?.id ?? 0)
            }
        }
    }

    private func fetchImage(id: Int) {
        networkManager.fetchImage(id: id) { [weak self] response in
            guard let self else { return }

            if let imageUrl = response?.output.first {
                removeBackground(imageUrl: imageUrl)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.fetchImage(id: id)
                    print("fetch")
                }
            }
        }
    }

    private func removeBackground(imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return }

        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                guard let imageWithoutBackground = try? BackgroundRemoval.init().removeBackground(image: response.image) else { return }

                currentSticker = imageWithoutBackground
                textToImage = Image(uiImage: imageWithoutBackground)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func exportSticker(image: UIImage) {
        let stickerSet = StickerSet(software: "Example Software", type: .image)
        if let stickerData = Sticker.StickerData(image: drawImage(image)) {
            try? stickerSet.addSticker(data: stickerData, emojis: ["😎"])
        }
        try? stickerSet.import()
    }

    private func drawImage(_ image: UIImage) -> UIImage {
        guard let coreImage = image.cgImage else {
            return UIImage()
        }
        UIGraphicsBeginImageContext(CGSize(width: coreImage.width, height: coreImage.height))
        image.draw(in: CGRect(x: 0, y: 0, width: coreImage.width, height: coreImage.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage ?? UIImage()
    }
}
