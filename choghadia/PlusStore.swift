// PlusStore.swift
// Choghadia Plus subscriptions with StoreKit 2 (auto-renewable, one subscription group).
// Payment always goes through Apple's own sheet. No other payment method is used.
//
// App Store Connect must define these two products in one subscription group:
//   socialcommerce.choghadia.plus.yearly   (1 year)
//   socialcommerce.choghadia.plus.monthly  (1 month)
// For local testing, attach Choghadia.storekit to the Run scheme
// (Product > Scheme > Edit Scheme > Run > Options > StoreKit Configuration).

import Observation
import StoreKit

@MainActor
@Observable
final class PlusStore {
    static let shared = PlusStore()

    enum Plan: String, CaseIterable, Identifiable {
        case yearly = "socialcommerce.choghadia.plus.yearly"
        case monthly = "socialcommerce.choghadia.plus.monthly"
        var id: String { rawValue }
    }

    enum PurchaseResult {
        case success
        case pending
        case cancelled
        case failed(String)
    }

    enum RestoreResult {
        case restored
        case nothingToRestore
        case failed(String)
    }

    private(set) var products: [Plan: Product] = [:]
    private(set) var isPlus = false
    private(set) var isLoadingProducts = false
    private(set) var isWorking = false

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    private init() {
        // Listen for renewals, Ask to Buy approvals and purchases made on other devices.
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update)
            }
        }
        Task {
            await refreshEntitlements()
            await loadProducts()
        }
    }

    // MARK: Products

    func loadProducts() async {
        guard products.isEmpty, !isLoadingProducts else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let loaded = try await Product.products(for: Plan.allCases.map(\.rawValue))
            var map: [Plan: Product] = [:]
            for product in loaded {
                if let plan = Plan(rawValue: product.id) { map[plan] = product }
            }
            products = map
        } catch {
            products = [:]
        }
    }

    func product(for plan: Plan) -> Product? { products[plan] }

    /// Localised price from the App Store, or nil until products load.
    func displayPrice(for plan: Plan) -> String? { products[plan]?.displayPrice }

    /// "Save 44%" computed from the live prices, or nil if unavailable.
    var yearlySavingPercent: Int? {
        guard let yearly = products[.yearly]?.price, let monthly = products[.monthly]?.price, monthly > 0 else { return nil }
        let full = monthly * 12
        guard full > yearly else { return nil }
        let saving = (full - yearly) / full * 100
        return NSDecimalNumber(decimal: saving).rounding(accordingToBehavior: nil).intValue
    }

    // MARK: Purchase and restore

    func purchase(_ plan: Plan) async -> PurchaseResult {
        if products.isEmpty { await loadProducts() }
        guard let product = products[plan] else {
            return .failed("Subscriptions aren't available right now. Please try again in a moment.")
        }
        isWorking = true
        defer { isWorking = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await refreshEntitlements()
                    return .success
                case .unverified:
                    return .failed("We couldn't verify this purchase with the App Store.")
                }
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            @unknown default:
                return .cancelled
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    /// Restore Purchases. Required in Settings and on the paywall.
    func restore() async -> RestoreResult {
        isWorking = true
        defer { isWorking = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            return isPlus ? .restored : .nothingToRestore
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    // MARK: Entitlements

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Plan(rawValue: transaction.productID) != nil,
               transaction.revocationDate == nil {
                active = true
            }
        }
        isPlus = active
    }

    private func handle(_ update: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = update else { return }
        await transaction.finish()
        await refreshEntitlements()
    }
}
