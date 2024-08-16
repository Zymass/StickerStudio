//
//  NetworkManager.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 29.11.2023.
//

import Alamofire
import Foundation
import FirebaseFunctions

protocol NetworkManagerProtocol {
    func getUserProfile(completion: @escaping (GetUserResponse?) -> ())
    func createSticker(prompt: String, completion: @escaping (Bool?) -> ())
    func fetchImage(id: Int, completion: @escaping (FetchImageResponse?) -> ())
    func updateUser(sticker: String, completion: @escaping (Bool) -> ())
}

final class NetworkManager: NetworkManagerProtocol {

    private lazy var functions = Functions.functions()
    private lazy var decoder = JSONDecoder()

    func getUserProfile(completion: @escaping (GetUserResponse?) -> ()) {
        functions.httpsCallable("get_user_info").call { result, error in
            if let anyData = result?.data, let data = try? JSONSerialization.data(withJSONObject: anyData, options: []) {
                do {
                    let response = try self.decoder.decode(
                        GetUserResponse.self,
                        from: data
                    )
                    completion(response)
                } catch {
                    completion(nil)
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }

    func createSticker(prompt: String, completion: @escaping (Bool?) -> ()) {

        let data: [String: Any] = [
            "prompt": prompt
        ]

        functions.httpsCallable("create_sticker").call(data) { [weak self] result, error in
            guard let self else { return }

            if let error {
                completion(false)
            } else {
                completion(true)
            }
//            if let anyData = result?.data, let data = try? JSONSerialization.data(withJSONObject: anyData, options: []) {
//                print("")
//                do {
//                    let response = try self.decoder.decode(
//                        GenerateImageResponse.self,
//                        from: data
//                    )
//                    completion(response)
//                } catch {
//                    completion(nil)
//                }
//            } else {
//                print(error?.localizedDescription ?? "")
//            }
        }
    }

    func fetchImage(id: Int, completion: @escaping (FetchImageResponse?) -> ()) {

        let data: [String: Any] = [
            "image_id": id
        ]

        functions.httpsCallable("fetch_image").call(data) { result, error in
            if let anyData = result?.data, let data = try? JSONSerialization.data(withJSONObject: anyData, options: []) {
                do {
                    let response = try self.decoder.decode(
                        FetchImageResponse.self,
                        from: data
                    )
                    completion(response)
                } catch {
                    completion(nil)
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }

    func updateUser(sticker: String, completion: @escaping (Bool) -> ()) {

        let data: [String: Any] = [
            "sticker": [sticker]
        ]

        functions.httpsCallable("update_user").call(data) { result, error in
            if let error {
                print(error.localizedDescription)
            } else {
                print("Update success")
            }
            completion(error == nil)
        }
    }
}
