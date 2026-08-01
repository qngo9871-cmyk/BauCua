import SwiftUI

struct HomeView: View {
    @EnvironmentObject var loc: LocalizationManager
    @StateObject private var purchases = PurchaseManager.shared
    @StateObject private var game = GameModel()

    @State private var showGame = false
    @State private var showRules = false
    @State private var showUpgrade = false
    @State private var showOnboarding = false
    @State private var showStats = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.25, green: 0.1, blue: 0.02), .black],
                                startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 26) {
                    Spacer()

                    VStack(spacing: 6) {
                        Text("🎲").font(.system(size: 56))
                        Text(L("home.title")).font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text(L("home.subtitle")).font(.subheadline).foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center).padding(.horizontal, 24)
                    }

                    VStack(spacing: 4) {
                        Text(L("chips.balance")).font(.caption).foregroundStyle(.white.opacity(0.6))
                        Text("\(game.chips)").font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.yellow)
                    }

                    VStack(spacing: 14) {
                        Button {
                            showGame = true
                        } label: {
                            Text(L("home.play")).font(.title3.bold()).frame(maxWidth: 280).padding()
                        }
                        .buttonStyle(.borderedProminent).tint(.orange)

                        HStack(spacing: 20) {
                            Button { showOnboarding = true } label: {
                                Text(L("home.howtoplay")).foregroundStyle(.white.opacity(0.85))
                            }
                            Button { showRules = true } label: {
                                Text(L("home.rules")).foregroundStyle(.white.opacity(0.85))
                            }
                            if purchases.isPro {
                                Button { showStats = true } label: {
                                    Text(L("home.stats")).foregroundStyle(.white.opacity(0.85))
                                }
                            }
                        }

                        if !purchases.isPro {
                            Button { showUpgrade = true } label: {
                                Text(L("home.upgrade")).font(.footnote).foregroundStyle(.yellow)
                            }
                        }
                    }

                    Spacer()

                    Picker("", selection: $loc.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 220)
                    .padding(.bottom, 24)
                }
                .padding()
            }
            .navigationDestination(isPresented: $showGame) {
                GameView(game: game)
            }
            .sheet(isPresented: $showRules) { RulesView() }
            .sheet(isPresented: $showUpgrade) { UpgradeView() }
            .sheet(isPresented: $showOnboarding) { OnboardingView(onFinished: { showOnboarding = false }) }
            .sheet(isPresented: $showStats) { StatsSheetView(game: game) }
            .task { await purchases.loadProduct() }
            .onAppear { game.unlimitedFreeRefills = purchases.isPro }
        }
    }
}

/// Pro-tier detailed stats screen (win streaks, biggest win, rounds played).
/// Not a separate target file per the project's structure spec — kept small
/// enough to live alongside HomeView.
private struct StatsSheetView: View {
    @ObservedObject var game: GameModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 22) {
                    Text("📊").font(.system(size: 44))
                    statRow(L("stats.roundsPlayed"), "\(game.roundsPlayed)")
                    statRow(L("stats.biggestWin"), "+\(game.biggestWin)")
                    statRow(L("stats.bestStreak"), "×\(game.bestStreak)")
                }
                .padding()
            }
            .navigationTitle(L("stats.title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("stats.close")) { dismiss() }
                }
            }
        }
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.white.opacity(0.75))
            Spacer()
            Text(value).font(.headline.monospacedDigit()).foregroundStyle(.yellow)
        }
        .padding()
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview { HomeView().environmentObject(LocalizationManager.shared) }
