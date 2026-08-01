import Foundation

/// The 6 faces used on each of the 3 dice in Bầu Cua Tôm Cá.
/// Emoji are placeholders — real dice-face art is a later step.
enum Symbol: String, CaseIterable, Identifiable, Codable {
    case bau, cua, tom, ca, ga, nai

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .bau: return "🍐" // gourd/calabash placeholder
        case .cua: return "🦀" // crab
        case .tom: return "🦐" // shrimp
        case .ca:  return "🐟" // fish
        case .ga:  return "🐓" // rooster
        case .nai: return "🦌" // deer/stag
        }
    }

    var titleKey: String {
        switch self {
        case .bau: return "symbol.bau"
        case .cua: return "symbol.cua"
        case .tom: return "symbol.tom"
        case .ca:  return "symbol.ca"
        case .ga:  return "symbol.ga"
        case .nai: return "symbol.nai"
        }
    }
}
