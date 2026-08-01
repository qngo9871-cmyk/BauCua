import SwiftUI

/// Grid of the 6 symbols where the player stages bets before rolling. Tap a
/// cell to add the currently-selected chip value to that symbol's bet;
/// long-press to clear just that symbol. Multiple simultaneous bets across
/// different symbols are allowed.
struct BetBoardView: View {
    @ObservedObject var game: GameModel
    let chipValue: Int

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Symbol.allCases) { symbol in
                cell(symbol)
            }
        }
    }

    private func cell(_ symbol: Symbol) -> some View {
        let amount = game.bets[symbol] ?? 0
        return VStack(spacing: 6) {
            Text(symbol.emoji).font(.system(size: 34))
            Text(L(symbol.titleKey)).font(.caption2).foregroundStyle(.white.opacity(0.8))
            Text(amount > 0 ? "\(amount)" : "—")
                .font(.footnote.monospacedDigit().bold())
                .foregroundStyle(amount > 0 ? .yellow : .white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(amount > 0 ? Color.yellow.opacity(0.16) : Color.white.opacity(0.06),
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(amount > 0 ? Color.yellow.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture { game.adjustBet(symbol, by: chipValue) }
        .onLongPressGesture { game.setBet(symbol, amount: 0) }
        .opacity(game.isRolling ? 0.5 : 1)
        .allowsHitTesting(!game.isRolling)
    }
}

#Preview {
    BetBoardView(game: GameModel(), chipValue: 10)
        .padding()
        .background(Color.black)
}
