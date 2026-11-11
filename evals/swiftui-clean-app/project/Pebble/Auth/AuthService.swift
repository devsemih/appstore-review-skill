import AuthenticationServices
import Foundation
import Observation

@Observable
@MainActor
final class AuthService {
    private(set) var isSignedIn = false
    private(set) var email: String?
    private var api = APIClient()
    private let keychain = KeychainStore(service: "app.pebblejournal.session")

    init() {
        if let token = keychain.read("sessionToken") {
            api.sessionToken = token
            isSignedIn = true
        }
    }

    /// Exchanges the Sign in with Apple identity token + authorization code for a Pebble session.
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async throws {
        guard case .success(let authorization) = result,
              let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }),
              let authCode = credential.authorizationCode.flatMap({ String(data: $0, encoding: .utf8) })
        else { return }

        struct Body: Encodable { let identityToken: String; let authorizationCode: String }
        struct Session: Decodable { let token: String; let email: String? }

        let session: Session = try await api.send("/auth/apple", method: "POST",
                                                  body: Body(identityToken: identityToken, authorizationCode: authCode))
        keychain.write(session.token, for: "sessionToken")
        api.sessionToken = session.token
        email = session.email
        isSignedIn = true
    }

    func signOut() {
        keychain.delete("sessionToken")
        api.sessionToken = nil
        isSignedIn = false
    }

    /// Permanently deletes the account: the backend erases all journal entries and
    /// revokes the Sign in with Apple token via Apple's REST API (/auth/revoke).
    func deleteAccount() async throws {
        let _: EmptyResponse = try await api.send("/account", method: "DELETE")
        signOut()
    }

    func authorizedClient() -> APIClient { api }
}

/// Minimal Keychain wrapper for the session token.
struct KeychainStore {
    let service: String

    func write(_ value: String, for key: String) {
        delete(key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: Data(value.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
