import SwiftUI

struct LockViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> LockViewController {
        return LockViewController()
    }
    
    func updateUIViewController(_ uiViewController: LockViewController, context: Context) {
        // Update the view controller if needed
    }
}
