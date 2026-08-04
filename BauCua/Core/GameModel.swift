import Foundation
import Combine

/// Solo Bầu Cua Tôm Cá. No AI opponent, no "difficulty" concept — the player
/// predicts which symbols the dice will show, then rolls, round after round.
///
/// COMPLIANCE (see CLAUDE.md): this is a pure prediction/scoring game, not a
/// wagering game. Predicting a symbol never stakes or risks anything — there
/// is no way to lose points, spend points, or run out of points. `score` only
/// ever goes up. Nothing in this app is purchasable with real money.
@MainActor
final class GameModel: ObservableObject {
    static let pointsPerMatch = 10

    @Published var score: Int {
        didSet { UserDefaults.standard.set(score, forKey: "bc_score") }
    }
    @Published var predictions: Set<Symbol> = []
    @Published var dice: [Symbol] = [.bau, .cua, .tom]
    @Published var isRolling = false
    @Published var lastResults: [GuessResult] = []
    @Published var lastPointsEarned: Int = 0

    @Published var roundsPlayed: Int {
        didSet { UserDefaults.standard.set(roundsPlayed, forKey: "bc_roundsPlayed") }
    }
    @Published var bestRoundScore: Int {
        didSet { UserDefaults.standard.set(bestRoundScore, forKey: "bc_bestRoundScore") }
    }
    @Published var bestStreak: Int {
        didSet { UserDefaults.standard.set(bestStreak, forKey: "bc_bestStreak") }
    }

    var canRoll: Bool { !predictions.isEmpty && !isRolling }

    init() {
        let d = UserDefaults.standard
        score = d.integer(forKey: "bc_score")
        roundsPlayed = d.integer(forKey: "bc_roundsPlayed")
        bestRoundScore = d.integer(forKey: "bc_bestRoundScore")
        bestStreak = d.integer(forKey: "bc_bestStreak")
    }

    // MARK: - Prediction phase

    func toggle(_ symbol: Symbol) {
        guard !isRolling else { return }
        if predictions.contains(symbol) {
            predictions.remove(symbol)
        } else {
            predictions.insert(symbol)
        }
    }

    func clearPredictions() {
        guard !isRolling else { return }
        predictions.removeAll()
    }

    // MARK: - Rolling

    func roll() {
        guard canRoll else { return }
        isRolling = true
        lastResults = []
        let predicted = predictions

        Task {
            try? await Task.sleep(nanoseconds: 900_000_000) // "shake the bowl" animation window
            let outcome = (0..<3).map { _ in Symbol.allCases.randomElement()! }
            settle(dice: outcome, predicted: predicted)
        }
    }

    private func settle(dice outcome: [Symbol], predicted: Set<Symbol>) {
        dice = outcome
        var results: [GuessResult] = []
        var earned = 0
        var maxMatchesThisRound = 0

        for symbol in predicted {
            let matches = outcome.filter { $0 == symbol }.count
            let result = GuessResult(symbol: symbol, matches: matches)
            results.append(result)
            earned += result.pointsEarned
            maxMatchesThisRound = max(maxMatchesThisRound, matches)
        }

        score += earned
        lastResults = results.sorted { $0.symbol.rawValue < $1.symbol.rawValue }
        lastPointsEarned = earned
        roundsPlayed += 1
        if lastPointsEarned > bestRoundScore { bestRoundScore = lastPointsEarned }
        if maxMatchesThisRound > bestStreak { bestStreak = maxMatchesThisRound }

        predictions.removeAll()
        isRolling = false
    }
}

#if DEBUG
extension GameModel {
    /// Deterministic states for App Store screenshot capture, keyed by BC_CAPTURE value.
    func captureSetup(_ scenario: String) {
        switch scenario {
        case "result":
            score = 1180
            dice = [.cua, .cua, .tom]
            lastResults = [
                GuessResult(symbol: .cua, matches: 2),
                GuessResult(symbol: .tom, matches: 1),
                GuessResult(symbol: .ga, matches: 0),
            ]
            lastPointsEarned = 2 * GameModel.pointsPerMatch + 1 * GameModel.pointsPerMatch
            roundsPlayed = 14
            bestRoundScore = 150
            bestStreak = 3
        case "rolling":
            score = 940
            predictions = [.bau, .ca]
            isRolling = true
        default: // "predicting"
            score = 1000
            predictions = [.cua, .tom, .ga]
        }
    }
}
#endif
