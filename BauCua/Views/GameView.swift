import SwiftUI

struct GameView: View {
    @ObservedObject var game: GameModel
    @StateObject private var purchases = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.03, blue: 0.02).ignoresSafeArea()

            VStack(spacing: 16) {
                header
                Spacer(minLength: 4)
                DiceBowlView(dice: game.dice, isRolling: game.isRolling)
                Spacer(minLength: 4)
                PredictionBoardView(game: game)
                    .padding(.horizontal)
                actionRow
            }
            .padding(.top, 8)
            .padding(.bottom, 12)

            if !game.lastResults.isEmpty && !game.isRolling {
                resultOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            VStack(spacing: 2) {
                Text(L("score.label")).font(.caption2).foregroundStyle(.white.opacity(0.5))
                Text("\(game.score)").font(.title3.bold().monospacedDigit()).foregroundStyle(.yellow)
            }
            Spacer()
            Color.clear.frame(width: 22, height: 22) // balances the xmark for centering
        }
        .padding(.horizontal)
    }

    private var actionRow: some View {
        HStack(spacing: 16) {
            Button(L("game.clearPicks")) { game.clearPredictions() }
                .buttonStyle(.bordered).tint(.gray)
                .disabled(game.isRolling || game.predictions.isEmpty)

            Button {
                game.roll()
            } label: {
                if game.isRolling {
                    ProgressView().tint(.white).frame(maxWidth: 160)
                } else {
                    Text(L("game.shake")).font(.title3.bold()).frame(maxWidth: 160)
                }
            }
            .buttonStyle(.borderedProminent).tint(.orange)
            .disabled(!game.canRoll)
        }
        .padding(.horizontal)
    }

    private var resultOverlay: some View {
        VStack(spacing: 14) {
            Text(game.dice.map { $0.emoji }.joined(separator: "  ")).font(.system(size: 38))

            Text(String(format: L("result.points"), game.lastPointsEarned))
                .font(.title2.bold())
                .foregroundStyle(game.lastPointsEarned > 0 ? .green : .white.opacity(0.7))

            VStack(spacing: 4) {
                ForEach(game.lastResults) { r in
                    HStack {
                        Text(r.symbol.emoji + " " + L(r.symbol.titleKey))
                        Spacer()
                        Text(r.matches > 0 ? "×\(r.matches) → +\(r.pointsEarned)" : L("result.noMatch"))
                            .foregroundStyle(r.matches > 0 ? .green : .white.opacity(0.6))
                    }
                    .font(.footnote)
                }
            }
            .frame(maxWidth: 260)

            Button(L("result.continue")) { game.lastResults = [] }
                .buttonStyle(.borderedProminent).tint(.orange)
        }
        .foregroundStyle(.white)
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(30)
    }
}

#Preview {
    let g = GameModel()
    g.predictions = [.cua, .tom]
    return NavigationStack { GameView(game: g) }.preferredColorScheme(.dark)
}
