import UIKit
import Combine

class LockViewController: UIViewController, UIGestureRecognizerDelegate {

    // Define UI elements
    private let lockView = LockView()
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    private var longPressGestureBeganPoint = CGPoint.zero
    private var isShowingLockView = false

    private let viewModel = ContentViewModel.shared
    private var cancellables = Set<AnyCancellable>()

    private var previousIsLocked: Bool = false
    private let animationDuration: TimeInterval = 0.2
    private let lockDistance: CGFloat = 100
    private let feedback = UIImpactFeedbackGenerator(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        
        viewModel.$isLocked
            .sink { [weak self] isLocked in
                guard let self = self else { return }
                
                if self.previousIsLocked && !isLocked {
                    // If previous state was locked and the new state is not locked
                    NSLog("LOG: Cancel button pressed, resetting lock view")
                    self.layoutForStopping()
                }
                
                // Update lock view based on current state
                self.lockView.isLocked = isLocked
                
                // Update previous state
                self.previousIsLocked = isLocked
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubview(lockView)
        lockView.translatesAutoresizingMaskIntoConstraints = false
        
        
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
            viewModel.isLocked = false
            lockView.progress = 0
            longPressGestureBeganPoint = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            let verticalDistance = longPressGestureBeganPoint.y - location.y
            if !viewModel.isLocked {
                let lockProgress = Float(verticalDistance / lockDistance)
                if lockProgress >= 1 {
                    viewModel.isLocked = true
                    lockView.performLockedIconZoomAnimation {
                        self.fadeOutLockView()
                    }
                } else {
                    lockView.progress = lockProgress
                }
            }
        case .ended:
            if !viewModel.isLocked {
                finishAction(sender)
            }
        case .cancelled:
            if !viewModel.isLocked {
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
        NSLog("LOG: layoutForStopping")
        UIView.animate(withDuration: animationDuration, animations: {
            self.lockView.progress = 0
            self.lockView.setNeedsLayout()
        })
    }
    
    private func animateShowLockView() {
        isShowingLockView = true
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateHideLockView() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.isShowingLockView = false
        }
    }
    
    
    private func fadeOutLockView() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.lockView.alpha = 0
        }) { _ in
            self.lockView.alpha = 1 // Reset alpha to 1 after fade-out
        }
    }
}

