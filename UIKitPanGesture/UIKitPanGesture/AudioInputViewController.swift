import UIKit
import AVFoundation

class AudioInputViewController: UIViewController, UIGestureRecognizerDelegate {

    // Define UI elements
    private let lockView = RecorderLockView()
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    private var longPressGestureBeganPoint = CGPoint.zero
    private var isShowingLockView = false
    private var isLocked = false {
        didSet {
            lockView.isLocked = isLocked
        }
    }
    
    private let animationDuration: TimeInterval = 0.2
    private let lockDistance: CGFloat = 100
    private let feedback = UIImpactFeedbackGenerator(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
    }
    
    private func setupUI() {
        view.addSubview(lockView)
        lockView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupGestureRecognizers() {
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.delegate = self
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            isLocked = false
            lockView.progress = 0
            longPressGestureBeganPoint = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            let verticalDistance = longPressGestureBeganPoint.y - location.y
            if !isLocked {
                let lockProgress = Float(verticalDistance / lockDistance)
                if lockProgress >= 1 {
                    isLocked = true
                    lockView.performLockedIconZoomAnimation {
                        self.fadeOutLockView()
                    }
                } else {
                    lockView.progress = lockProgress
                }
            }
        case .ended:
            if !isLocked {
                finishAction()
            }
        case .cancelled:
            if !isLocked {
                cancelAction()
            }
        default:
            break
        }
    }
    
    
    
    private func animateShowLockView() {
        isShowingLockView = true
    }
    
    private func animateHideLockView() {
        isShowingLockView = false
    }
    
    private func fadeOutLockView() {
        UIView.animate(withDuration: animationDuration) {
            self.lockView.alpha = 0
        } completion: { _ in
//            self.lockView.alpha = 1
        }
    }
    
    private func finishAction() {
        animateHideLockView()
    }
    
    private func cancelAction() {
        animateHideLockView()
    }
    
}

