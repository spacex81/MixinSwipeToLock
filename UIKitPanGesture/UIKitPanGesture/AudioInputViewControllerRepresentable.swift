import SwiftUI

struct AudioInputViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> AudioInputViewController {
        return AudioInputViewController()
    }
    
    func updateUIViewController(_ uiViewController: AudioInputViewController, context: Context) {
        // Update the view controller if needed
    }
}
