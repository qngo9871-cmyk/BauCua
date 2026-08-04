import Foundation

/// Outcome of a single predicted symbol after a roll. Matching a symbol
/// always earns points — there is no way to lose points, since predictions
/// never stake anything of value. See CLAUDE.md compliance note.
struct GuessResult: Identifiable, Equatable {
    let id = UUID()
    let symbol: Symbol
    let matches: Int

    /// Points earned from this one predicted symbol (0 if it didn't match).
    var pointsEarned: Int { matches * GameModel.pointsPerMatch }
}
