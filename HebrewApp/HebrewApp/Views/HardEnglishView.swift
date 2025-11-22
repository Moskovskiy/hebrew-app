import SwiftUI

struct HardEnglishView: View {
    @StateObject private var controller = HardEnglishGameController()
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated Background - Green for English theme
            LinearGradient(colors: [Color(red: 0.0, green: 0.4, blue: 0.1), 
                                   Color(red: 0.1, green: 0.5, blue: 0.2), 
                                   Color(red: 0.0, green: 0.3, blue: 0.05)], 
                          startPoint: animateGradient ? .topLeading : .bottomLeading, 
                          endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            
            VStack {
                // Score Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Success")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(controller.scoreCorrect)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Miss")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(controller.scoreWrong)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .padding(.horizontal)
                .padding()
                
                Spacer()
                
                // Game Content
                HardEnglishExerciseView(controller: controller)
                
                Spacer()
                
                // Feedback Overlay
                if let message = controller.feedbackMessage {
                    Text(message)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(controller.isCorrectAnswer ? .green : .red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.7))
                        )
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                }
            }
        }
    }
}
