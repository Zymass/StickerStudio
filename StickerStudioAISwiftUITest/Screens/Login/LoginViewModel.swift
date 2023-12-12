//
//  LoginViewModel.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 09.11.2023.
//

import Combine
import FirebaseAuth
import SwiftUI
import CryptoKit
import AuthenticationServices

enum LoginViewEvents {
    case pressRegistration
}

enum LoginViewOutput {
    case didCompleteLogin(_ userData: GetUserResponse)
}

final class LoginViewModel: NSObject, ObservableObject {

    @AppStorage("uid") private var uid: String?
    @EnvironmentObject var authorizationState: Authorization
    let events = PassthroughSubject<LoginViewEvents, Never>()
    fileprivate var currentNonce: String?

    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager()

    init(authorization: EnvironmentObject<Authorization>) {
        self._authorizationState = authorization

        super.init()
        binding()
    }

    private func binding() {
        events
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .pressRegistration:
                    Task {
                        await self.signIn()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func signIn() async {
        startSignInWithAppleFlow()
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

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                guard let self else { return }

                if let error {
                    print(error.localizedDescription)
                } else {
                    uid = authResult?.user.uid
                    authorizationState.isAuthorized = true
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}
