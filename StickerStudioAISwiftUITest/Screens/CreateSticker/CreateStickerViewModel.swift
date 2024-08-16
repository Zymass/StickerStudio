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
import FirebaseFirestore
import BackgroundRemoval

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
    @Published var showAlert: Bool = false
    @AppStorage("uid") private var uid: String?
    private var currentSticker: UIImage?
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private lazy var storage = Storage.storage()
    private lazy var backgroundRemoval = BackgroundRemoval()
    private var currentStickerId: String?

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

        networkManager.createSticker(prompt: prompt + "Sticker, contour, Vector, White Background, cartoon style, sticker 2d, diecut sticker –v 4 –upbeta –q 2 –v 5 –s 750, no outline") { [weak self] result in
            guard let self else { return }

            if result == true {
                subscribeToUserChanges()
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
        showAlert = true
    }
    
    private func subscribeToUserChanges() {
        guard listener == nil else { return }
        
        listener = db.collection("users").document(uid ?? "").addSnapshotListener(includeMetadataChanges: true) { [weak self] snapshot, error in
            guard
                let self,
                let snapshot,
                !snapshot.metadata.isFromCache,
                let data = snapshot.data(),
                let stickers = data["stickers"] as? [String],
                let stickerId = stickers.last else {
                return
            }

            guard stickerId != currentStickerId else { return }
            
            currentStickerId = stickerId
            getSticker(stickerId: stickerId)
            print("🚺\(stickers)")
        }
    }
    
    private func removeSubscribtion() {
        listener?.remove()
        listener = nil
    }
    
    private func getSticker(stickerId: String) {
        storage.reference().child("users/\(uid ?? "")/createdStickers/\(stickerId).jpg").getData(maxSize: 1024 * 1024) { [weak self] data, error in
            guard let self else { return }
            
            if let data, let image = UIImage(data: data) {
                do {
                    let imageWithoutBackground = try backgroundRemoval.removeBackground(image: image)
                    self.textToImage = Image(uiImage: imageWithoutBackground)
                    self.currentSticker = imageWithoutBackground
                    self.isLoading = false
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
            
            removeSubscribtion()
        }
    }
}
