import SwiftUI

struct WordHintView: View {
    let word: Word
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack {
            if let root = word.root, let construction = word.construction {
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: isExpanded ? "chevron.up" : "lightbulb.fill")
                            .foregroundColor(isExpanded ? .white : .yellow)
                        Text(isExpanded ? "Hide Hint" : "Show Hint")
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .background(.ultraThinMaterial)
                    )
                    .foregroundColor(.white)
                }
                
                if isExpanded {
                    VStack(spacing: 12) {
                        // Root Letters
                        HStack(spacing: 15) {
                            Text("Root:")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            HStack(spacing: 5) {
                                ForEach(root, id: \.self) { letter in
                                    Text(letter)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 30, height: 30)
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.15))
                                        )
                                }
                            }
                            .environment(\.layoutDirection, .rightToLeft)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Construction Explanation
                        Text(construction)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                            .background(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                }
            }
        }
    }
}
