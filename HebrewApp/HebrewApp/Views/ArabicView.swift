import SwiftUI

struct ArabicView: View {
    @StateObject private var controller = ArabicGameController()
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated Background - Deep Red/Purple for Arabic theme
            LinearGradient(colors: [Color(red: 0.1, green: 0.0, blue: 0.05), 
                                   Color(red: 0.15, green: 0.05, blue: 0.1), 
                                   Color(red: 0.05, green: 0.0, blue: 0.05)], 
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
                .padding(.horizontal)
                .padding()
                
                Spacer()
                
                // Game Content
                ArabicExerciseView(controller: controller)
                
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
