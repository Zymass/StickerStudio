//
//  TextToImageResponse.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.12.2023.
//

import Foundation

struct GenerateImageResponse: Codable {
    let result: String?
    let responseData: TextToImageData?
}

struct TextToImageData: Codable {
    let status: String?
    let generationTime: Double?
    let id: Int?
    let output: [String]?
    let proxyLinks: [String]?
    let nsfwContentDetected: Bool?
    let webhookStatus: String?
    let meta: Meta?
    let tip: String?

    enum CodingKeys: String, CodingKey {
        case status, generationTime, id, output
        case proxyLinks = "proxy_links"
        case nsfwContentDetected = "nsfw_content_detected"
        case webhookStatus = "webhook_status"
        case meta, tip
    }
}

struct Meta: Codable {
    let prompt, modelId, negativePrompt, scheduler: String?
    let safetyChecker: String?
    let width, height: Int?
    let guidanceScale: Double?
    let seed, steps, nSamples: Int?
    let fullURL, instantResponse, tomesd, freeU: String?
    let upscale: Int?
    let multiLingual, panorama, selfAttention, useKarrasSigmas: String?
    let algorithmType, safetyCheckerType: String?
    let embeddings, vae: String?
    let lora, loraStrength: String?
    let clipSkip: Int?
    let temp, base64, filePrefix: String?

    enum CodingKeys: String, CodingKey {
        case prompt
        case modelId = "model_id"
        case negativePrompt = "negative_prompt"
        case scheduler
        case safetyChecker = "safety_checker"
        case width = "W"
        case height = "H"
        case guidanceScale = "guidance_scale"
        case seed, steps
        case nSamples = "n_samples"
        case fullURL = "full_url"
        case instantResponse = "instant_response"
        case tomesd
        case freeU = "free_u"
        case upscale
        case multiLingual = "multi_lingual"
        case panorama
        case selfAttention = "self_attention"
        case useKarrasSigmas = "use_karras_sigmas"
        case algorithmType = "algorithm_type"
        case safetyCheckerType = "safety_checker_type"
        case embeddings, vae, lora
        case loraStrength = "lora_strength"
        case clipSkip = "clip_skip"
        case temp, base64
        case filePrefix = "file_prefix"
    }
}
