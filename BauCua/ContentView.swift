import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        #if DEBUG
        if let lang = ProcessInfo.processInfo.environment["BC_LANG"], let l = AppLanguage(rawValue: lang) {
            LocalizationManager.shared.setLanguage(l)
        }
        if let capture = ProcessInfo.processInfo.environment["BC_CAPTURE"], capture != "home" {
            if capture == "onboarding" {
                return AnyView(OnboardingView(onFinished: {}).preferredColorScheme(.dark))
            }
            if capture == "upgrade" {
                return AnyView(UpgradeView().preferredColorScheme(.dark))
            }
            if capture == "rules" {
                return AnyView(RulesView().preferredColorScheme(.dark))
            }
            let game = GameModel()
            game.captureSetup(capture)
            return AnyView(NavigationStack { GameView(game: game) }.preferredColorScheme(.dark))
        }
        // capture == "home" (or BC_SKIP_ONBOARDING) both mean "show the real home
        // screen, not onboarding" — a fresh simulator install always has
        // hasSeenOnboarding == false, so without this the "home" screenshot would
        // actually capture the onboarding flow instead.
        if ProcessInfo.processInfo.environment["BC_CAPTURE"] == "home" {
            return AnyView(HomeView())
        }
        if ProcessInfo.processInfo.environment["BC_SKIP_ONBOARDING"] != nil {
            return AnyView(HomeView())
        }
        #endif
        if !hasSeenOnboarding {
            return AnyView(OnboardingView(onFinished: { hasSeenOnboarding = true }))
        }
        return AnyView(HomeView())
    }
}

#Preview { ContentView() }
