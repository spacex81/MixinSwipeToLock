import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("SwiftUI View with UIKit Component")
            AudioInputViewControllerRepresentable()
                .frame(height: 300) // Set the desired height or other constraints
        }
    }
}
