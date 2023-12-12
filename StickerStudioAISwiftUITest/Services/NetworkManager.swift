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
    func getStickerImage(prompt: String, completion: @escaping (TextToImageResponse?) -> ())
    func fetchImage(id: Int, completion: @escaping (FetchImageResponse?) -> ())
}

final class NetworkManager: NetworkManagerProtocol {

    private lazy var functions = Functions.functions()
    private lazy var decoder = JSONDecoder()
    private lazy var key: String = "Xg1DySGHAkq5GcftYzv3kCwJigG3VfNHGuwBMcBM9flzu77smKXYdp4r728V"

    // Generate image

    func getStickerImage(prompt: String, completion: @escaping (TextToImageResponse?) -> ()) {
        guard let url = URL(string: "https://stablediffusionapi.com/api/v4/dreambooth") else { return }

        let parameter = TextToImageRequestModel(
            key: key,
            modelId: "anything-v4",
            prompt: "\(prompt), contour, Vector, White Background, cartoon style, sticker 2d, diecut sticker –v 4 –upbeta –q 2 –v 5 –s 750, no outline",
            negativePrompt: "",
            width: 512,
            height: 512,
            samples: 1,
            numInferenceSteps: 31,
            safetyChecker: "no",
            enhancePrompt: "no",
            seed: nil,
            guidanceScale: 7.5,
            multiLingual: "no",
            panorama: "no",
            selfAttention: "no",
            upscale: 1,
            embeddingsModel: nil,
            loraModel: "stickermodel",
            tomesd: "yes",
            clipSkip: 2,
            useKarrasSigmas: "yes",
            vae: nil,
            loraStrength: 0.5,
            scheduler: "UniPCMultistepScheduler",
            webhook: nil,
            trackId: nil
        )

        AF.request(
            url,
            method: .post,
            parameters: parameter,
            encoder: JSONParameterEncoder.default
        ).response { [weak self] response in

            guard let self else { return completion(nil) }

            switch response.result {
            case .success(let data):
                guard let data else { return completion(nil) }

                do {
                    let response = try self.decoder.decode(
                        TextToImageResponse.self,
                        from: data
                    )
                    completion(response)
                } catch {
                    completion(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }

    // Get unready image

    func fetchImage(id: Int, completion: @escaping (FetchImageResponse?) -> ()) {
        guard let url = URL(string: "https://stablediffusionapi.com/api/v4/dreambooth/fetch") else { return }

        let parameter = FetchImageRequestModel(key: key, requestId: id)

        AF.request(
            url,
            method: .post,
            parameters: parameter,
            encoder: URLEncodedFormParameterEncoder.default
        ).response { [weak self] response in

            guard let self else { return completion(nil) }

            switch response.result {
            case .success(let data):
                guard let data else { return completion(nil) }

                do {
                    let response = try self.decoder.decode(
                        FetchImageResponse.self,
                        from: data
                    )
                    completion(response)
                } catch {
                    completion(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }

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
                print(error?.localizedDescription)
            }
        }
    }
}
