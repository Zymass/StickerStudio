//
//  CreateStickerViewModel.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.10.2023.
//

import SwiftUI
import Combine
import Kingfisher
import FirebaseStorage

enum CreateStickerViewEvents {
    case tapMainButton
    case exportToTelegram
    case tapSaveImage
}

final class CreateStickerViewModel: NSObject, ObservableObject {
    @Published var positivePrompts: [Prompt] = []
    @Published var textToImage: Image = Image(.defaultSticker)
    @Published var isLoading: Bool = false
    @Published var isTelegramButtinHidden: Bool = true
    @AppStorage("uid") private var uid: String?
    private var currentSticker: UIImage?

    let events = PassthroughSubject<CreateStickerViewEvents, Never>()
    private lazy var networkManager = NetworkManager()

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        binding()
    }

    private func binding() {
        events
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .tapMainButton:
                    textToImageRequest()
                    isTelegramButtinHidden = true
                case .exportToTelegram:
                    guard let currentSticker else { return }

                    exportSticker(image: currentSticker)
                case .tapSaveImage:
                    guard let currentSticker else { return }
                    
                    writeToPhotoAlbum(image: currentSticker)
                }
            }
            .store(in: &cancellables)
    }

    private func textToImageRequest() {
        let prompt = positivePrompts.map { $0.value }.joined(separator: ", ")
        isLoading = true
        isTelegramButtinHidden = true

        networkManager.createSticker(prompt: prompt + "Sticker, contour, Vector, White Background, cartoon style, sticker 2d, diecut sticker –v 4 –upbeta –q 2 –v 5 –s 750, no outline") { [weak self] response in
            guard let self else { return }

            if let imageUrl = response?.responseData?.output?.first {
                removeBackground(imageUrl: imageUrl)
            } else {
                fetchImage(id: response?.responseData?.id ?? 0)
            }
        }
    }

    private func fetchImage(id: Int) {
        networkManager.fetchImage(id: id) { [weak self] response in
            guard let self else { return }

            if let imageUrl = response?.responseData?.output?.first {
                removeBackground(imageUrl: imageUrl)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
                let imageWithoutBackground = response.image

                isLoading = false
                currentSticker = imageWithoutBackground
                textToImage = Image(uiImage: imageWithoutBackground)
                isTelegramButtinHidden = false
                uploadImageToCloudStorage()
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

    private func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(UIImage(data: image.pngData()!)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        print("Did finish saving")
    }

    private func uploadImageToCloudStorage() {
        let storage = Storage.storage()

        // Create a root reference
        let storageRef = storage.reference()

        guard let data = currentSticker?.pngData() else { return }

        // Create a reference to the file you want to upload
        let path = "stickers/\(uid ?? "error")/\(randomNonceString(length: 32))"
        let riversRef = storageRef.child(path)

        // Upload the file to the path
        _ = riversRef.putData(data, metadata: nil) { [weak self] (metadata, error) in
            guard let self else { return }

            if metadata != nil {
                networkManager.updateUser(sticker: path) { result in
                    print("Update user success: \(result)")
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
}
