import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @Environment(AuthService.self) private var auth
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "book.closed.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Pebble Journal")
                .font(.largeTitle.bold())
            Text("A calm place for your daily thoughts, synced privately across your devices.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email]
            } onCompletion: { result in
                Task {
                    do { try await auth.handleAppleSignIn(result) }
                    catch { errorMessage = "Sign in failed. Please try again." }
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52)
            if let errorMessage {
                Text(errorMessage).font(.footnote).foregroundStyle(.red)
            }
            HStack(spacing: 16) {
                Link("Privacy Policy", destination: Links.privacy)
                Link("Terms of Use", destination: Links.terms)
            }
            .font(.footnote)
        }
        .padding(32)
    }
}

enum Links {
    static let privacy = URL(string: "https://pebblejournal.app/privacy")!
    static let terms = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let support = URL(string: "https://pebblejournal.app/support")!
}
