import LocalAuthentication
import Observation
import SwiftUI

@Observable
@MainActor
final class AppLock {
    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "appLockEnabled") }
    }
    private(set) var isLocked: Bool

    init() {
        let enabled = UserDefaults.standard.bool(forKey: "appLockEnabled")
        isEnabled = enabled
        isLocked = enabled
    }

    func unlock() async {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            isLocked = false
            return
        }
        do {
            isLocked = !(try await context.evaluatePolicy(.deviceOwnerAuthentication,
                                                          localizedReason: "Unlock your journal"))
        } catch {
            isLocked = true
        }
    }
}

struct LockedView: View {
    @Environment(AppLock.self) private var lock

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill").font(.largeTitle)
            Text("Your journal is locked")
            Button("Unlock") { Task { await lock.unlock() } }
                .buttonStyle(.borderedProminent)
        }
        .task { await lock.unlock() }
    }
}
