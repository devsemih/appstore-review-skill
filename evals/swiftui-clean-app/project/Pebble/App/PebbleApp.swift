import SwiftUI

@main
struct PebbleApp: App {
    @State private var auth = AuthService()
    @State private var store = StoreManager()
    @State private var lock = AppLock()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(auth)
                .environment(store)
                .environment(lock)
                .task { await store.start() }
        }
    }
}

struct RootView: View {
    @Environment(AuthService.self) private var auth
    @Environment(AppLock.self) private var lock

    var body: some View {
        Group {
            if !auth.isSignedIn {
                SignInView()
            } else if lock.isLocked {
                LockedView()
            } else {
                JournalListView()
            }
        }
        .animation(.default, value: auth.isSignedIn)
    }
}
