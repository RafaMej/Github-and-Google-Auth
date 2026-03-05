
//
//  GitHubSignInManager.swift
//  StudentApp
//

import Foundation
import FirebaseAuth

class GitHubSignInManager {

    static let shared = GitHubSignInManager()

    func signIn() async throws -> AuthDataResult {

        let provider = OAuthProvider(providerID: "github.com")
        provider.scopes = ["user:email"]

        return try await withCheckedThrowingContinuation { continuation in

            provider.getCredentialWith(nil) { credential, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let credential = credential else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "GitHubAuth",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "No credential returned"]
                        )
                    )
                    return
                }

                Auth.auth().signIn(with: credential) { result, error in

                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let result = result else {
                        continuation.resume(
                            throwing: NSError(
                                domain: "GitHubAuth",
                                code: -2,
                                userInfo: [NSLocalizedDescriptionKey: "No auth result"]
                            )
                        )
                        return
                    }

                    continuation.resume(returning: result)
                }
            }
        }
    }
}
