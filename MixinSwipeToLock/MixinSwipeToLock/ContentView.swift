import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel.shared
    
    var body: some View {
        VStack {
            AudioInputViewControllerRepresentable()
            if viewModel.isLocked {
                Button {
                    viewModel.isLocked = false
                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark) // Set dark mode for the preview
}
