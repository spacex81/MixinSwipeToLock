import SwiftUI

struct RecorderLockViewRepresentable: UIViewRepresentable {
    
    var isLocked: Bool
    var progress: Float
    var onLockedIconZoomAnimationCompletion: () -> Void
    
    func makeUIView(context: Context) -> RecorderLockView {
        let recorderLockView = RecorderLockView()
        return recorderLockView
    }
    
    func updateUIView(_ uiView: RecorderLockView, context: Context) {
        uiView.isLocked = isLocked
        uiView.progress = progress
        
        // If you need to trigger the zoom animation from SwiftUI
        if isLocked {
            uiView.performLockedIconZoomAnimation(completion: onLockedIconZoomAnimationCompletion)
        }
    }
}
