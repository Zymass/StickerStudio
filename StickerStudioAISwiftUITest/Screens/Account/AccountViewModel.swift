//
//  AccountViewModel.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 19.12.2023.
//

import SwiftUI
import FirebaseStorage
import BackgroundRemoval

final class AccountViewModel: ObservableObject {
    @Published var stickerModels = [AccountStickerModel]()
    @AppStorage("uid") private var uid: String?
    private lazy var storage = Storage.storage()
    private lazy var backgroundRemoval = BackgroundRemoval()

    init() {
        getImages()
    }

    private func getImages() {
        Task {
            storage.reference().child("users/\(uid ?? "")/createdStickers/").listAll(completion: { [weak self, weak storage] result, error in
                guard let self else { return }

                result?.items.forEach { item in
                    let reference = storage?.reference(withPath: item.fullPath)
                    
                    reference?.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                        guard let data, let uiImage = UIImage(data: data) else { return }
                        
                        DispatchQueue.main.async {
                            do {
                                let resultImage = try self.backgroundRemoval.removeBackground(image: uiImage)
                                self.stickerModels.append(AccountStickerModel(image: Image(uiImage: resultImage)))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            })
        }
    }
}
