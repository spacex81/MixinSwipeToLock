import SwiftUI

struct ContentView: View {
    @State private var isLocked: Bool = false
    @State private var progress: Float = 0.0

    var body: some View {
        VStack {
            RecorderLockViewRepresentable(isLocked: isLocked, progress: progress) {
                print("Locked icon zoom animation completed")
            }
            .frame(width: 200, height: 300) // Set frame size as needed
            .padding()
            
            // Buttons to simulate state changes
            Button("Lock") {
                isLocked = true
            }
            .padding()
            
            Button("Unlock") {
                isLocked = false
            }
            .padding()
            
            Slider(value: $progress, in: 0...1)
                .padding()
        }
    }
}
