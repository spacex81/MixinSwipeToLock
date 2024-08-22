import UIKit

class AudioInputViewController: UIViewController, UIGestureRecognizerDelegate {

    // Define UI elements
    private let lockView = LockView()
    
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
        
        lockView.layer.borderColor = UIColor.red.cgColor
        lockView.layer.borderWidth = 2.0
        
        NSLayoutConstraint.activate([
            lockView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lockView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            lockView.widthAnchor.constraint(equalToConstant: 150), // Adjust size as needed
            lockView.heightAnchor.constraint(equalToConstant: 150) // Adjust size as needed
        ])
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
                finishAction(sender)
            }
        case .cancelled:
            if !isLocked {
                cancelAction(sender)
            }
        case .possible, .failed:
            break
        @unknown default:
            break
        }
    }
    
    func cancelAction(_ sender: Any) {
        layoutForStopping()
        animateHideLockView()
    }
    
    func finishAction(_ sender: Any) {
        layoutForStopping()
        animateHideLockView()
    }
    
    private func layoutForStopping() {
        if isLocked {
        } else {
//            fadeOutLockView()
        }
        UIView.animate(withDuration: animationDuration, animations: {
            self.lockView.progress = 0
            self.preferredContentSize.width = self.view.frame.height
        }) { (_) in
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
}

