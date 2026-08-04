import SwiftUI

/// Grid of the 6 symbols where the player picks their predictions before
/// rolling. Tap a symbol to toggle it on/off. Multiple simultaneous
/// predictions are allowed — no amounts, no stakes, just a guess.
struct PredictionBoardView: View {
    @ObservedObject var game: GameModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Symbol.allCases) { symbol in
                cell(symbol)
            }
        }
    }

    private func cell(_ symbol: Symbol) -> some View {
        let picked = game.predictions.contains(symbol)
        return VStack(spacing: 6) {
            Text(symbol.emoji).font(.system(size: 34))
            Text(L(symbol.titleKey)).font(.caption2).foregroundStyle(.white.opacity(0.8))
            Image(systemName: picked ? "checkmark.circle.fill" : "circle")
                .font(.footnote.bold())
                .foregroundStyle(picked ? .yellow : .white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(picked ? Color.yellow.opacity(0.16) : Color.white.opacity(0.06),
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(picked ? Color.yellow.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture { game.toggle(symbol) }
        .opacity(game.isRolling ? 0.5 : 1)
        .allowsHitTesting(!game.isRolling)
    }
}

#Preview {
    PredictionBoardView(game: GameModel())
        .padding()
        .background(Color.black)
}
