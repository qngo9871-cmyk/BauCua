import SwiftUI

struct GameView: View {
    @ObservedObject var game: GameModel
    @StateObject private var purchases = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var chipValue = 10
    @State private var tick = 0
    private let chipValues = [10, 50, 100, 500]

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.03, blue: 0.02).ignoresSafeArea()

            VStack(spacing: 16) {
                header
                Spacer(minLength: 4)
                DiceBowlView(dice: game.dice, isRolling: game.isRolling)
                Spacer(minLength: 4)
                chipValuePicker
                BetBoardView(game: game, chipValue: chipValue)
                    .padding(.horizontal)
                actionRow
            }
            .padding(.top, 8)
            .padding(.bottom, 12)

            if !game.lastResults.isEmpty && !game.isRolling {
                resultOverlay
            }
            if game.chips <= 0 && game.bets.isEmpty && game.lastResults.isEmpty {
                topUpOverlay.id(tick)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { game.unlimitedFreeRefills = purchases.isPro }
        .onChange(of: purchases.isPro) { isPro in game.unlimitedFreeRefills = isPro }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if game.chips <= 0 { tick += 1 }
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            VStack(spacing: 2) {
                Text(L("chips.balance")).font(.caption2).foregroundStyle(.white.opacity(0.5))
                Text("\(game.chips)").font(.title3.bold().monospacedDigit()).foregroundStyle(.yellow)
            }
            Spacer()
            Color.clear.frame(width: 22, height: 22) // balances the xmark for centering
        }
        .padding(.horizontal)
    }

    private var chipValuePicker: some View {
        HStack(spacing: 10) {
            ForEach(chipValues, id: \.self) { v in
                Button {
                    chipValue = v
                } label: {
                    Text("\(v)")
                        .font(.footnote.bold())
                        .frame(width: 52, height: 32)
                        .background(chipValue == v ? Color.yellow : Color.white.opacity(0.1), in: Capsule())
                        .foregroundStyle(chipValue == v ? .black : .white)
                }
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 16) {
            Button(L("game.clearBets")) { game.clearBets() }
                .buttonStyle(.bordered).tint(.gray)
                .disabled(game.isRolling || game.bets.isEmpty)

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

            Text(game.lastNetChange >= 0
                 ? String(format: L("result.win"), game.lastNetChange)
                 : String(format: L("result.lose"), abs(game.lastNetChange)))
                .font(.title2.bold())
                .foregroundStyle(game.lastNetChange >= 0 ? .green : .red)

            VStack(spacing: 4) {
                ForEach(game.lastResults) { r in
                    HStack {
                        Text(r.symbol.emoji + " " + L(r.symbol.titleKey))
                        Spacer()
                        Text(r.matches > 0 ? "×\(r.matches) → +\(r.netChange)" : "−\(r.staked)")
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

    private var topUpOverlay: some View {
        VStack(spacing: 16) {
            Text("🎲").font(.system(size: 44))
            Text(L("topup.title")).font(.title3.bold()).foregroundStyle(.white)
            if game.topUpAvailable {
                Text(String(format: L("topup.body"), GameModel.freeTopUpAmount))
                    .font(.subheadline).foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                Button(L("topup.claim")) { game.claimFreeTopUp() }
                    .buttonStyle(.borderedProminent).tint(.orange)
            } else {
                Text(String(format: L("topup.wait"), formattedCooldown))
                    .font(.subheadline).foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(40)
    }

    private var formattedCooldown: String {
        let s = Int(game.topUpCooldownRemaining)
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}

#Preview {
    let g = GameModel()
    g.bets = [.cua: 20, .tom: 10]
    return NavigationStack { GameView(game: g) }.preferredColorScheme(.dark)
}
