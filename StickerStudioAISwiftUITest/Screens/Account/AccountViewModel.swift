//
//  AccountViewModel.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 19.12.2023.
//

import SwiftUI
import FirebaseStorage

final class AccountViewModel: ObservableObject {
    @Published var stickerModels = [AccountStickerModel]()
    @AppStorage("uid") private var uid: String?
    private lazy var storage = Storage.storage()

    init() {
        getImages()
    }

    private func getImages() {
        Task {
            storage.reference().child("stickers/\(uid ?? "error")/").listAll(completion: { [weak self, weak storage] result, error in
                guard let self else { return }

                result?.items.forEach {
                    let reference = storage?.reference(withPath: $0.fullPath)

                    reference?.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                        guard let data, let uiImage = UIImage(data: data) else { return }

                        self.stickerModels.append(AccountStickerModel(image: Image(uiImage: uiImage)))
                    }
                }
            })
        }
    }
}
