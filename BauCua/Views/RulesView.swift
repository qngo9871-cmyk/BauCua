import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    private let sections: [(String, String)] = [
        ("rules.symbols.title", "rules.symbols.body"),
        ("rules.betting.title", "rules.betting.body"),
        ("rules.roll.title", "rules.roll.body"),
        ("rules.payout.title", "rules.payout.body"),
        ("rules.topup.title", "rules.topup.body"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(sections, id: \.0) { title, body in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L(title)).font(.headline)
                            Text(L(body)).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(L("rules.title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("rules.done")) { dismiss() }
                }
            }
        }
    }
}

#Preview { RulesView() }
