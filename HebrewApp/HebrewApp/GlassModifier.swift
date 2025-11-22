import SwiftUI

struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func glass() -> some View {
        self.modifier(GlassModifier())
    }
}
