import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isPro = false
    @Published var product: Product?
    @Published var isLoadingProduct = false
    @Published var productLoadFailed = false
    @Published var isPurchasing = false
    @Published var purchaseError: String?
    @Published var trialActive = true

    private let productID = "com.quyenngo.baucua.pro"
    private var transactionListener: Task<Void, Never>?

    private let firstLaunchKey = "firstLaunchDate"
    private let trialDuration: TimeInterval = 7 * 24 * 60 * 60

    /// Days left in the 7-day free trial (0 once expired).
    var trialDaysRemaining: Int {
        let defaults = UserDefaults.standard
        guard let firstLaunch = defaults.object(forKey: firstLaunchKey) as? Date else { return 7 }
        let remaining = trialDuration - Date().timeIntervalSince(firstLaunch)
        return max(0, Int(ceil(remaining / (24 * 60 * 60))))
    }

    init() {
        transactionListener = listenForTransactions()
        evaluateTrialStatus()
        Task { await updateEntitlementStatus() }
    }

    /// Reads (or sets, on first-ever launch) the trial start date and
    /// updates `trialActive`. Existing installs upgrading from a pre-trial
    /// build have no stored date yet, so this update starts their 7-day
    /// clock rather than locking them out immediately.
    func evaluateTrialStatus() {
        let defaults = UserDefaults.standard
        let now = Date()
        let firstLaunch: Date
        if let stored = defaults.object(forKey: firstLaunchKey) as? Date {
            firstLaunch = stored
        } else {
            firstLaunch = now
            defaults.set(now, forKey: firstLaunchKey)
        }
        trialActive = Date().timeIntervalSince(firstLaunch) < trialDuration
    }

    deinit { transactionListener?.cancel() }

    func loadProduct() async {
        isLoadingProduct = true
        productLoadFailed = false
        do {
            let products = try await withTimeout(seconds: 10) {
                try await Product.products(for: [self.productID])
            }
            product = products.first
            if product == nil { productLoadFailed = true }
        } catch {
            productLoadFailed = true
        }
        isLoadingProduct = false
    }

    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw CancellationError()
            }
            guard let result = try await group.next() else { throw CancellationError() }
            group.cancelAll()
            return result
        }
    }

    func purchase() async {
        guard let product else {
            purchaseError = "Product not available. Please try again."
            return
        }
        isPurchasing = true
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                // Grant on both .verified AND .unverified — treating unverified as a hard
                // failure silently drops legitimate purchases (JWS edge cases, StoreKit
                // sandbox quirks). Finish the transaction either way so it doesn't retry forever.
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    isPro = true
                case .unverified(let transaction, _):
                    await transaction.finish()
                    isPro = true
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                purchaseError = "An unexpected error occurred."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    func restorePurchases() async {
        isPurchasing = true
        purchaseError = nil
        do {
            try await AppStore.sync()
        } catch {
            purchaseError = "Could not restore purchases. Please try again."
            isPurchasing = false
            return
        }
        await updateEntitlementStatus()
        if !isPro { purchaseError = "No purchase found to restore." }
        isPurchasing = false
    }

    func updateEntitlementStatus() async {
        #if DEBUG
        // Double-gating bug fix (2026-08-24, portfolio-wide compliance-gate finding):
        // a bare `isPro = true` here masked the real free-tier/trial state on every
        // Debug run and every "home"/"upgrade" screenshot capture, the same class of
        // bug already fixed in SamLoc/Fanorona/Dara/Surakarta. Only force-unlock for
        // capture scenarios that are supposed to show unlocked content.
        let capture = ProcessInfo.processInfo.environment["BC_CAPTURE"]
        isPro = capture != nil && capture != "home" && capture != "upgrade"
        #else
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction), .unverified(let transaction, _):
                if transaction.productID == productID, transaction.revocationDate == nil {
                    isPro = true
                    return
                }
            }
        }
        isPro = false
        #endif
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction), .unverified(let transaction, _):
                    await transaction.finish()
                    await self?.updateEntitlementStatus()
                }
            }
        }
    }
}

// NOTE (compliance — do not change without re-reading CLAUDE.md):
// This IAP is a single non-consumable "Pro" unlock. It must NEVER be
// extended into a points pack / currency / wager purchase. Pro unlocks
// cosmetic and QoL features only (alternate themes, detailed stats, no
// ads) — it never touches scoring, odds, or introduces anything that could
// be staked or wagered. This app has no gambling mechanic of any kind.
//
// The 7-day trialActive gate below controls ACCESS to playing at all — it
// does not touch scoring/odds/matches, so it doesn't reintroduce anything
// wager-like. Gating play itself is a standing portfolio-wide rule (see
// feedback_no_permanent_free_tier_trials_only), independent of the
// gambling-descriptor compliance constraint above.
