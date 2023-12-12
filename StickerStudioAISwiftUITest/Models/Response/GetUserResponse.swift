//
//  GetUserResponse.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 09.12.2023.
//

import Foundation

struct GetUserResponse: Codable {
    let result: UserModel
}

struct UserModel: Codable {
    let generationsDone: Int
    let uid: String
    let creationTime: String
    let lastSignInTime: Int
    let email: String
    let freeGenerationrequestDate: Int
    let generations: Int
}
