import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            AudioInputViewControllerRepresentable()
                .frame(height: 300) // Set the desired height or other constraints
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark) // Set dark mode for the preview
}
