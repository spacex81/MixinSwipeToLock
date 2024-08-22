import UIKit
import AVFoundation

class AudioInputViewController: UIViewController, UIGestureRecognizerDelegate {

    // Define UI elements
    private let recordingIndicatorView = UIView()
    private let recordingRedDotView = UIView()
    private let timeLabel = UILabel()
    private let slideToCancelView = UIView()
    private let slideToCancelContentView = UIStackView()
    private let recordImageView = UIImageView()
    private let lockView = RecorderLockView()
    private let lockedActionsView = UIView()
    
    private var recordGestureRecognizer: UILongPressGestureRecognizer!
    
    private var recordGestureBeganPoint = CGPoint.zero
    private var recordDuration: TimeInterval = 0
    private var isShowingLockView = false
    private var isLocked = false {
        didSet {
            lockView.isLocked = isLocked
            lockedActionsView.isHidden = !isLocked
        }
    }
    
    private weak var recordDurationTimer: Timer?
    
    private let animationDuration: TimeInterval = 0.2
    private let slideToCancelDistance: CGFloat = 80
    private let lockDistance: CGFloat = 100
    private let feedback = UIImpactFeedbackGenerator(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
    }
    
    private func setupUI() {
        // Setup views and add them to the view hierarchy
        view.addSubview(recordingIndicatorView)
        view.addSubview(recordingRedDotView)
        view.addSubview(timeLabel)
        view.addSubview(slideToCancelView)
        slideToCancelView.addSubview(slideToCancelContentView)
        view.addSubview(recordImageView)
        view.addSubview(lockView)
        view.addSubview(lockedActionsView)
        
        // Configure layout for views
        // Add your constraints or frames setup here
        
        lockView.translatesAutoresizingMaskIntoConstraints = false
        lockedActionsView.translatesAutoresizingMaskIntoConstraints = false
        recordingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        recordingRedDotView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        slideToCancelView.translatesAutoresizingMaskIntoConstraints = false
        slideToCancelContentView.translatesAutoresizingMaskIntoConstraints = false
        recordImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup initial view configurations here
    }
    
    private func setupGestureRecognizers() {
        recordGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        recordGestureRecognizer.delegate = self
        view.addGestureRecognizer(recordGestureRecognizer)
    }
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            isLocked = false
            lockView.progress = 0
//            recordImageView.tintColor = .theme
            startRecordingIfGranted()
            recordGestureBeganPoint = sender.location(in: view)
            slideToCancelContentView.alpha = 1
        case .changed:
            let location = sender.location(in: view)
            let horizontalDistance = max(0, recordGestureBeganPoint.x - location.x)
            slideToCancelContentView.alpha = 1 - horizontalDistance / slideToCancelDistance
            if horizontalDistance > slideToCancelDistance {
                sender.isEnabled = false
                sender.isEnabled = true
            } else {
                // Update slide view constraints based on horizontalDistance
            }
            let verticalDistance = recordGestureBeganPoint.y - location.y
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
    
    private func startRecordingIfGranted() {
    }
    
    private func startRecording() {
        feedback.prepare()
        layoutForRecording()
        recordDuration = 0
        setTimeLabelValue(0)
    }
    
    private func layoutForRecording() {
        animateShowLockView()
        // Update other UI elements for recording state
    }
    
    private func layoutForStopping() {
        if isLocked {
            slideToCancelView.alpha = 0
        } else {
            fadeOutLockView()
        }
        UIView.animate(withDuration: animationDuration) {
            self.recordingIndicatorView.alpha = 0
            self.lockedActionsView.alpha = self.isLocked ? 0 : 1
        }
    }
    
    private func animateShowLockView() {
        isShowingLockView = true
        // Update constraints to show lock view
    }
    
    private func animateHideLockView() {
        isShowingLockView = false
        // Update constraints to hide lock view
    }
    
    private func fadeOutLockView() {
        UIView.animate(withDuration: animationDuration) {
            self.lockView.alpha = 0
        } completion: { _ in
            self.lockView.alpha = 1
        }
    }
    
    private func finishAction() {
        layoutForStopping()
        animateHideLockView()
    }
    
    private func cancelAction() {
        layoutForStopping()
        animateHideLockView()
    }
    
    private func setTimeLabelValue(_ value: TimeInterval) {
        timeLabel.text = String(format: "%.0f", value)
    }
}

