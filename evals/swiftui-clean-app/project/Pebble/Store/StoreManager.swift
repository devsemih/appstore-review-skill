import Foundation
import Observation
import StoreKit

@Observable
@MainActor
final class StoreManager {
    static let productIDs = ["app.pebblejournal.plus.monthly", "app.pebblejournal.plus.yearly"]

    private(set) var products: [Product] = []
    private(set) var hasPlus = false
    private var updatesTask: Task<Void, Never>?

    func start() async {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
        await loadProducts()
        await refreshEntitlements()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        if case .success(.verified(let transaction)) = result {
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    /// Restore Purchases: syncs with the App Store and re-reads current entitlements.
    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var active = false
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement,
               Self.productIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                active = true
            }
        }
        hasPlus = active
    }
}
