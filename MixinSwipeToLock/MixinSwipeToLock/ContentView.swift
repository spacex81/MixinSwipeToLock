import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            AudioInputViewControllerRepresentable()
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark) // Set dark mode for the preview
}
