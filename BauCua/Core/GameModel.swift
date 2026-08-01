import Foundation
import Combine

/// Solo-vs-the-house Bầu Cua Tôm Cá. No AI opponent, no "difficulty" concept —
/// the player bets chips against the dice, round after round.
///
/// COMPLIANCE (see CLAUDE.md): `chips` is a pure simulation currency. It is
/// never purchasable with real money anywhere in this app. If the balance
/// hits 0, the player always gets a FREE top-up (immediate the first time,
/// then time-gated — Pro removes the wait, it does not sell chips).
@MainActor
final class GameModel: ObservableObject {
    static let startingChips = 1000
    static let freeTopUpAmount = 500
    static let freeTopUpCooldown: TimeInterval = 60 * 60 * 4 // 4 hours

    @Published var chips: Int {
        didSet { UserDefaults.standard.set(chips, forKey: "bc_chips") }
    }
    @Published var bets: [Symbol: Int] = [:]
    @Published var dice: [Symbol] = [.bau, .cua, .tom]
    @Published var isRolling = false
    @Published var lastResults: [BetResult] = []
    @Published var lastNetChange: Int = 0

    @Published var roundsPlayed: Int {
        didSet { UserDefaults.standard.set(roundsPlayed, forKey: "bc_roundsPlayed") }
    }
    @Published var biggestWin: Int {
        didSet { UserDefaults.standard.set(biggestWin, forKey: "bc_biggestWin") }
    }
    @Published var bestStreak: Int {
        didSet { UserDefaults.standard.set(bestStreak, forKey: "bc_bestStreak") }
    }
    @Published var lastFreeTopUpDate: Date? {
        didSet { UserDefaults.standard.set(lastFreeTopUpDate, forKey: "bc_lastFreeTopUp") }
    }

    /// Set true when Pro is owned. Removes the free-top-up wait — still
    /// free, never a paid mechanic. See PurchaseManager.swift compliance note.
    var unlimitedFreeRefills = false

    var totalBet: Int { bets.values.reduce(0, +) }
    var canRoll: Bool { totalBet > 0 && totalBet <= chips && !isRolling }

    init() {
        let d = UserDefaults.standard
        chips = (d.object(forKey: "bc_chips") as? Int) ?? GameModel.startingChips
        roundsPlayed = d.integer(forKey: "bc_roundsPlayed")
        biggestWin = d.integer(forKey: "bc_biggestWin")
        bestStreak = d.integer(forKey: "bc_bestStreak")
        lastFreeTopUpDate = d.object(forKey: "bc_lastFreeTopUp") as? Date
    }

    // MARK: - Betting phase

    /// Adjust the stake on one symbol by `delta` chips, clamped to what's
    /// left of the current balance after other symbols' stakes.
    func adjustBet(_ symbol: Symbol, by delta: Int) {
        guard !isRolling else { return }
        let current = bets[symbol] ?? 0
        let spentElsewhere = totalBet - current
        let capped = max(0, min(current + delta, chips - spentElsewhere))
        setBet(symbol, amount: capped)
    }

    func setBet(_ symbol: Symbol, amount: Int) {
        guard !isRolling else { return }
        if amount <= 0 {
            bets.removeValue(forKey: symbol)
        } else {
            bets[symbol] = amount
        }
    }

    func clearBets() {
        guard !isRolling else { return }
        bets.removeAll()
    }

    // MARK: - Rolling

    func roll() {
        guard canRoll else { return }
        isRolling = true
        lastResults = []
        let staked = bets
        chips -= totalBet // stakes leave the balance immediately; returned per the payout table in settle()

        Task {
            try? await Task.sleep(nanoseconds: 900_000_000) // "shake the bowl" animation window
            let outcome = (0..<3).map { _ in Symbol.allCases.randomElement()! }
            settle(dice: outcome, staked: staked)
        }
    }

    private func settle(dice outcome: [Symbol], staked: [Symbol: Int]) {
        dice = outcome
        var results: [BetResult] = []
        var returned = 0
        var maxMatchesThisRound = 0

        for (symbol, amount) in staked {
            let matches = outcome.filter { $0 == symbol }.count
            let result = BetResult(symbol: symbol, staked: amount, matches: matches)
            results.append(result)
            returned += result.totalReturned
            maxMatchesThisRound = max(maxMatchesThisRound, matches)
        }

        chips += returned
        lastResults = results.sorted { $0.symbol.rawValue < $1.symbol.rawValue }
        lastNetChange = returned - staked.values.reduce(0, +)
        roundsPlayed += 1
        if lastNetChange > biggestWin { biggestWin = lastNetChange }
        if maxMatchesThisRound > bestStreak { bestStreak = maxMatchesThisRound }

        bets.removeAll()
        isRolling = false
    }

    // MARK: - Free chip top-up (never paid)

    var topUpAvailable: Bool {
        guard chips <= 0 else { return false }
        if unlimitedFreeRefills { return true }
        guard let last = lastFreeTopUpDate else { return true } // first time ever: instant, no wait
        return Date().timeIntervalSince(last) >= GameModel.freeTopUpCooldown
    }

    var topUpCooldownRemaining: TimeInterval {
        guard let last = lastFreeTopUpDate else { return 0 }
        return max(0, GameModel.freeTopUpCooldown - Date().timeIntervalSince(last))
    }

    /// Player taps "Claim Free Chips" — never a paid path, see CLAUDE.md.
    func claimFreeTopUp() {
        guard chips <= 0, topUpAvailable else { return }
        chips = GameModel.freeTopUpAmount
        lastFreeTopUpDate = Date()
    }
}

#if DEBUG
extension GameModel {
    /// Deterministic states for App Store screenshot capture, keyed by BC_CAPTURE value.
    func captureSetup(_ scenario: String) {
        switch scenario {
        case "result":
            chips = 1180
            dice = [.cua, .cua, .tom]
            lastResults = [
                BetResult(symbol: .cua, staked: 50, matches: 2),
                BetResult(symbol: .tom, staked: 20, matches: 1),
                BetResult(symbol: .ga, staked: 30, matches: 0),
            ]
            lastNetChange = 50 * 2 + 20 * 1 - 30
            roundsPlayed = 14
            biggestWin = 150
            bestStreak = 3
        case "rolling":
            chips = 940
            bets = [.bau: 20, .ca: 40]
            isRolling = true
        default: // "betting"
            chips = 1000
            bets = [.cua: 50, .tom: 20, .ga: 30]
        }
    }
}
#endif
