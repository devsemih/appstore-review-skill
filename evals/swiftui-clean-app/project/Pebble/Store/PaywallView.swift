import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Product?
    @State private var isPurchasing = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pebble Plus")
                        .font(.largeTitle.bold())
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Unlimited journal entries", systemImage: "infinity")
                        Label("Custom themes and fonts", systemImage: "paintpalette")
                        Label("Encrypted iCloud backup", systemImage: "lock.icloud")
                    }

                    ForEach(store.products) { product in
                        Button {
                            selected = product
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.displayName).font(.headline)
                                    Text("\(product.displayPrice) per \(periodText(for: product))")
                                        .font(.subheadline)
                                }
                                Spacer()
                                Image(systemName: selected?.id == product.id ? "checkmark.circle.fill" : "circle")
                            }
                            .padding()
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }

                    if let selected {
                        Text("\(selected.displayPrice) per \(periodText(for: selected)). Subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Your Apple Account is charged at confirmation and for each renewal. Manage or cancel anytime in your App Store account settings.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        Task { await buy() }
                    } label: {
                        Text(selected.map { "Subscribe for \($0.displayPrice)/\(periodText(for: $0))" } ?? "Choose a plan")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(selected == nil || isPurchasing)

                    HStack {
                        Button("Restore Purchases") {
                            Task {
                                do {
                                    try await store.restorePurchases()
                                    message = store.hasPlus ? "Pebble Plus restored." : "No previous purchases found."
                                } catch {
                                    message = "Restore failed. Please try again."
                                }
                            }
                        }
                        Spacer()
                        Link("Terms of Use", destination: Links.terms)
                        Link("Privacy", destination: Links.privacy)
                    }
                    .font(.footnote)

                    if let message {
                        Text(message).font(.footnote)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear { selected = store.products.last }
        }
    }

    private func buy() async {
        guard let selected else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await store.purchase(selected)
            if store.hasPlus { dismiss() }
        } catch {
            message = "Purchase could not be completed."
        }
    }

    private func periodText(for product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return "" }
        switch period.unit {
        case .month: return period.value == 1 ? "month" : "\(period.value) months"
        case .year: return period.value == 1 ? "year" : "\(period.value) years"
        case .week: return "week"
        case .day: return "\(period.value) days"
        @unknown default: return ""
        }
    }
}
