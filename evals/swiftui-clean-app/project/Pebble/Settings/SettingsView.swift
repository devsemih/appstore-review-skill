import SwiftUI

struct SettingsView: View {
    @Environment(AuthService.self) private var auth
    @Environment(StoreManager.self) private var store
    @Environment(AppLock.self) private var lock
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @State private var showPaywall = false

    var body: some View {
        @Bindable var lock = lock
        Form {
            Section("Security") {
                Toggle("Lock with Face ID", isOn: $lock.isEnabled)
            }

            Section("Pebble Plus") {
                if store.hasPlus {
                    Label("Pebble Plus is active", systemImage: "checkmark.seal.fill")
                    Link("Manage Subscription", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                } else {
                    Button("Upgrade to Pebble Plus") { showPaywall = true }
                }
                Button("Restore Purchases") {
                    Task { try? await store.restorePurchases() }
                }
            }

            Section("About") {
                Link("Privacy Policy", destination: Links.privacy)
                Link("Terms of Use", destination: Links.terms)
                Link("Contact Support", destination: Links.support)
            }

            Section {
                Button("Sign Out") { auth.signOut() }
                Button("Delete Account", role: .destructive) { showDeleteConfirmation = true }
                    .disabled(isDeleting)
            } footer: {
                Text("Deleting your account permanently removes your journal entries from our servers. Active subscriptions are managed by Apple and must be cancelled separately in Settings.")
            }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .confirmationDialog("Delete your account?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Account Permanently", role: .destructive) {
                Task {
                    isDeleting = true
                    defer { isDeleting = false }
                    do { try await auth.deleteAccount() }
                    catch { errorMessage = "We couldn't delete your account. Please try again or contact support." }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your account and all journal entries. This cannot be undone.")
        }
    }
}
