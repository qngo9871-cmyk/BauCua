import SwiftUI

/// The three dice inside the "bát" (bowl). Animates a shake while rolling,
/// then reveals the settled symbols. Simple SwiftUI offset/rotation jitter —
/// no elaborate physics needed for v1.
struct DiceBowlView: View {
    let dice: [Symbol]
    let isRolling: Bool

    @State private var shakeOffsets: [CGSize] = [.zero, .zero, .zero]
    @State private var shakeRotations: [Double] = [0, 0, 0]

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [Color.brown.opacity(0.55), Color(red: 0.32, green: 0.18, blue: 0.08)],
                                      center: .center, startRadius: 10, endRadius: 130))
                .overlay(Circle().stroke(Color.yellow.opacity(0.55), lineWidth: 4))
                .frame(width: 220, height: 220)
                .shadow(radius: 10)

            HStack(spacing: 14) {
                ForEach(0..<3, id: \.self) { i in
                    Text(dice[i].emoji)
                        .font(.system(size: 46))
                        .frame(width: 64, height: 64)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 3)
                        .offset(shakeOffsets[i])
                        .rotationEffect(.degrees(shakeRotations[i]))
                }
            }
        }
        .onChange(of: isRolling) { rolling in
            if rolling { startShake() } else { stopShake() }
        }
    }

    private func startShake() {
        withAnimation(.easeInOut(duration: 0.1).repeatCount(9, autoreverses: true)) {
            shakeOffsets = (0..<3).map { _ in CGSize(width: .random(in: -12...12), height: .random(in: -10...10)) }
            shakeRotations = (0..<3).map { _ in Double.random(in: -18...18) }
        }
    }

    private func stopShake() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            shakeOffsets = [.zero, .zero, .zero]
            shakeRotations = [0, 0, 0]
        }
    }
}

#Preview {
    DiceBowlView(dice: [.bau, .cua, .tom], isRolling: false)
        .padding()
        .background(Color.black)
}
