//
//  TextToImageRequestModel.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 29.11.2023.
//

import Foundation

struct TextToImageRequestModel: Encodable {
    let key: String
    let modelId: String
    let prompt: String
    let negativePrompt: String?
    let width: Int
    let height: Int
    let samples: Int
    let numInferenceSteps: Int
    let safetyChecker: String
    let enhancePrompt: String
    let seed: String?
    let guidanceScale: Double
    let multiLingual: String
    let panorama: String
    let selfAttention: String
    let upscale: Int
    let embeddingsModel: String?
    let loraModel: String
    let tomesd: String
    let clipSkip: Int
    let useKarrasSigmas: String
    let vae: String?
    let loraStrength: Double
    let scheduler: String
    let webhook: String?
    let trackId: String?

    enum CodingKeys: String, CodingKey {
        case key, prompt, width, height, samples, seed, panorama, upscale, tomesd, vae, scheduler, webhook
        case modelId = "model_id"
        case negativePrompt = "negative_prompt"
        case numInferenceSteps = "num_inference_steps"
        case safetyChecker = "safety_checker"
        case enhancePrompt = "enhance_prompt"
        case guidanceScale = "guidance_scale"
        case multiLingual = "multi_lingual"
        case selfAttention = "self_attention"
        case embeddingsModel = "embeddings_model"
        case loraModel = "lora_model"
        case clipSkip = "clip_skip"
        case useKarrasSigmas = "use_karras_sigmas"
        case loraStrength = "lora_strength"
        case trackId = "track_id"
    }
}
