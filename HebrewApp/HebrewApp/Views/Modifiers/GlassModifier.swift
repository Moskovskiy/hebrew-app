import SwiftUI

struct LiquidGlassBackground: View {
    @State private var startPoint: UnitPoint = .topLeading
    @State private var endPoint: UnitPoint = .bottomTrailing

    var body: some View {
        LinearGradient(
            colors: [
                Color.cyan,
                Color.blue,
                Color.purple,
                Color.pink
            ],
            startPoint: startPoint,
            endPoint: endPoint
        )
        .blur(radius: 40)
        .saturation(1.3)
        .onAppear {
            withAnimation(
                .linear(duration: 8)
                    .repeatForever(autoreverses: true)
            ) {
                startPoint = .bottomTrailing
                endPoint = .topLeading
            }
        }
    }
}

struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    // Liquid, moving color behind the glass
                    LiquidGlassBackground()
                        .opacity(0.6)
                        .blendMode(.screen)

                    // Subtle base tint to keep it readable
                    Color.white.opacity(0.08)
                }
                .background(.ultraThinMaterial)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(
                // Bright edge highlight for that glass rim
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(0.25),
                radius: 30,
                x: 0,
                y: 20
            )
    }
}

extension View {
    /// Apply a "liquid glass" effect
    func glass() -> some View {
        self.modifier(GlassModifier())
    }
}