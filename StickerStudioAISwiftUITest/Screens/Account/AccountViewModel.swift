//
//  AccountViewModel.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 19.12.2023.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

final class AccountViewModel: ObservableObject {
    @Published var stickerModels = [AccountStickerModel]()
    @AppStorage("uid") private var uid: String?
    private lazy var storage = Storage.storage()

    init() {
        getImages()
        subscribeToUserChanges()
    }
    
    deinit {
        removeSubscribtion()
    }

    private func getImages() {
        Task {
            storage.reference().child("users/\(uid ?? "")/createdStickers/").listAll(completion: { [weak self, weak storage] result, error in
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
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private func subscribeToUserChanges() {
//        listener = db.collection("users").document(uid ?? "")
//          .addSnapshotListener { documentSnapshot, error in
//            guard let document = documentSnapshot else {
//              print("Error fetching document: \(error!)")
//              return
//            }
//            guard let data = document.data() else {
//              print("Document data was empty.")
//              return
//            }
//            print("Current data: \(data)")
//          }  
        
//        listener = db.collection("users").document(uid ?? "").addSnapshotListener({ snapshot, error in
//            print(snapshot)
//            print(error)
//        })
    }
    
    private func removeSubscribtion() {
//        listener?.remove()
    }
}
