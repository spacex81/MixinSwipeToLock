import UIKit
import Combine

class DraggableViewController: UIViewController {

    private let draggableView = UIView()
    private let statusIcon = UIImageView()
    private var longPressRecognized = false
    private var initialCenterY: CGFloat = 0.0
    private var maxUpwardDistance: CGFloat = 0.0
    private var viewModel = ContentViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var shimmerLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up draggable view
        draggableView.backgroundColor = .blue
        draggableView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        draggableView.layer.cornerRadius = 50
        view.addSubview(draggableView)
        
        // Set up status icon
        statusIcon.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        statusIcon.contentMode = .scaleAspectFit
        view.addSubview(statusIcon)

        // Center the draggable view and status icon
        centerDraggableView()
        
        // Calculate the maximum upward distance
        let screenHeight = view.bounds.height
        maxUpwardDistance = screenHeight * 0.10 // 10% of the screen height
        
        // Add gesture recognizers
        setupGestures()
        
        viewModel.$isLocked
            .sink { [weak self] isLocked in
                self?.updateStatusIcon(isLocked: isLocked)
                if !isLocked {
                    self?.animateViewBackToOriginalPosition()
                    self?.removeShimmerEffect()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupShimmerEffect() {
        // Create the shimmer layer
        let shimmerLayer = CAGradientLayer()
        let shimmerHeight = maxUpwardDistance + draggableView.bounds.height
        shimmerLayer.frame = CGRect(x: 0, y: 0, width: draggableView.bounds.width, height: shimmerHeight)
        
        shimmerLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        shimmerLayer.locations = [0.0, 0.5, 1.0]
        
        // Create the animation to move shimmer effect from top to bottom
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = -shimmerHeight
        animation.duration = 1.5
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "shimmerAnimation")
        
        // Create a mask layer to apply the half-circle shape at the top
        let maskLayer = CAShapeLayer()
        let radius = draggableView.bounds.width / 2
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: draggableView.bounds.width, height: shimmerHeight), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        
        maskLayer.path = path.cgPath
        shimmerLayer.mask = maskLayer
        
        // Add the shimmer layer to the draggable view
        draggableView.layer.addSublayer(shimmerLayer)
        self.shimmerLayer = shimmerLayer
    }
    
    private func removeShimmerEffect() {
        shimmerLayer?.removeFromSuperlayer()
        shimmerLayer = nil
    }

    private func centerDraggableView() {
        // Calculate the center of the screen
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        
        // Set the draggable view's center
        draggableView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        initialCenterY = draggableView.center.y
        
        // Calculate the position for the status icon
        let iconOffset: CGFloat = 10 // Offset above the draggable view
        statusIcon.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        statusIcon.center = CGPoint(x: draggableView.center.x, y: draggableView.frame.minY - statusIcon.bounds.height / 2 - iconOffset)
    }

    private func setupGestures() {
        // Long press gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        draggableView.addGestureRecognizer(longPressRecognizer)
        
        // Pan gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        draggableView.addGestureRecognizer(panRecognizer)
        
        // Enable simultaneous gesture recognition
        draggableView.gestureRecognizers?.forEach {
            $0.delegate = self
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            longPressRecognized = true
            setupShimmerEffect()
        } else if gesture.state == .ended {
            longPressRecognized = false
            // Animate back to the original position if not locked
            if !viewModel.isLocked {
                animateViewBackToOriginalPosition()
            }
            removeShimmerEffect()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard longPressRecognized else { return }

        let translation = gesture.translation(in: view)
        guard let draggedView = gesture.view else { return }

        // Get the touch point in the view's coordinate space
        let touchPoint = gesture.location(in: view)
        
        // Determine if the touch is below the circle's center
        let isTouchBelowCenter = touchPoint.y < draggableView.center.y

        if gesture.state == .began || gesture.state == .changed {
            // Only update the center if moving upwards and within bounds and the touch is below the circle's center
            if isTouchBelowCenter {
                let newCenterY = draggedView.center.y + translation.y
                let minAllowedY = initialCenterY - maxUpwardDistance

                if newCenterY >= minAllowedY && newCenterY <= initialCenterY {
                    draggedView.center = CGPoint(x: draggedView.center.x, y: newCenterY)
                    
                    // Set isLocked if the view has reached the minAllowedY
                    if newCenterY <= minAllowedY + 10 {
                        if !viewModel.isLocked {
                            NSLog("LOG: is locked")
                            viewModel.isLocked = true
                        }
                    }
                }
            }
            gesture.setTranslation(.zero, in: view)
        } else if gesture.state == .ended {
            longPressRecognized = false
            // Animate back to the original position if not locked
            if !viewModel.isLocked {
                animateViewBackToOriginalPosition()
            }
            removeShimmerEffect()
        }
    }

    private func animateViewBackToOriginalPosition() {
        UIView.animate(withDuration: 0.3, animations: {
            self.draggableView.center = CGPoint(x: self.view.bounds.width / 2, y: self.initialCenterY)
            self.statusIcon.center = CGPoint(x: self.draggableView.center.x, y: self.draggableView.frame.minY - self.statusIcon.bounds.height / 2)
        })
    }
    
    private func updateStatusIcon(isLocked: Bool) {
        let iconName = isLocked ? "lock.fill" : "lock.open.fill" // Use appropriate SF Symbols names or your own images
        statusIcon.image = UIImage(systemName: iconName)
    }
}

extension DraggableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
