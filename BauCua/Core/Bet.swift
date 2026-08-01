import Foundation

/// A single staged bet: chips staked on one symbol for the round about to be
/// rolled. GameModel keeps the live staging area as `[Symbol: Int]`; this
/// type is used for display and for settled results.
struct Bet: Identifiable, Equatable {
    let id = UUID()
    let symbol: Symbol
    var amount: Int
}

/// Outcome of a single settled bet after a roll, per the standard payout
/// table: 0 matches loses the stake; 1/2/3 matches returns the stake plus
/// stake × matches (net gain = stake × matches).
struct BetResult: Identifiable, Equatable {
    let id = UUID()
    let symbol: Symbol
    let staked: Int
    let matches: Int

    /// Net chip change from this single bet (negative = lost the stake).
    var netChange: Int { matches > 0 ? staked * matches : -staked }

    /// Total chips returned to the balance for this bet (0 if it lost).
    var totalReturned: Int { matches > 0 ? staked + staked * matches : 0 }
}
