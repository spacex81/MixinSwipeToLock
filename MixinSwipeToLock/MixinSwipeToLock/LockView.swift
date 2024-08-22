import UIKit

class LockView: UIView {
   
    static let backgroundImage = R.image.conversation.bg_recorder_lock()!
    static let shackleImage = R.image.conversation.ic_recorder_lock_shackle()!
    static let lockBodyImage = R.image.conversation.ic_recorder_lock_body()!
    static let lockedImage = R.image.conversation.ic_recorder_lock_locked()!
    static let directionIndicationImage = R.image.conversation.ic_recorder_lock_direction_up()!
    
    let backgroundImageView = UIImageView(image: LockView.backgroundImage)
    let lockShackleImageView = UIImageView(image: LockView.shackleImage)
    let lockBodyImageView = UIImageView(image: LockView.lockBodyImage)
    let directionIndicatorImageView = UIImageView(image: LockView.directionIndicationImage)
    
    private let lockedIconZoomingTransform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    private let lockedIconZoomingAnimationDuration: TimeInterval = 0.2
    
    var isLocked = false {
        didSet {
            backgroundImageView.isHidden = isLocked
            lockShackleImageView.isHidden = isLocked
            lockBodyImageView.isHidden = isLocked
            directionIndicatorImageView.isHidden = isLocked
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return BackgroundSize.start
    }
    
    var progress: Float = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLocked {
            let progress = max(0, min(1, CGFloat(self.progress)))
            
            let centerX = (bounds.width - BackgroundSize.start.width) / 2

            // Calculate the background origin and size
            let backgroundOriginX = BackgroundOrigin.start.x + (BackgroundOrigin.end.x - BackgroundOrigin.start.x) * progress
            let backgroundOriginY = BackgroundOrigin.start.y + (BackgroundOrigin.end.y - BackgroundOrigin.start.y) * progress
            let backgroundWidth = BackgroundSize.start.width + (BackgroundSize.end.width - BackgroundSize.start.width) * progress
            let backgroundHeight = BackgroundSize.start.height + (BackgroundSize.end.height - BackgroundSize.start.height) * progress

            backgroundImageView.frame = CGRect(
                origin: CGPoint(x: centerX + backgroundOriginX, y: backgroundOriginY),
                size: CGSize(width: backgroundWidth, height: backgroundHeight)
            )

            // Calculate the lock body center
            let lockBodyCenterX = LockBodyCenter.start.x + (LockBodyCenter.end.x - LockBodyCenter.start.x) * progress
            let lockBodyCenterY = LockBodyCenter.start.y + (LockBodyCenter.end.y - LockBodyCenter.start.y) * progress
            lockBodyImageView.center = CGPoint(x: centerX + lockBodyCenterX, y: lockBodyCenterY)

            // Calculate the lock shackle center
            let lockShackleCenterX = LockShackleCenter.start.x + (LockShackleCenter.end.x - LockShackleCenter.start.x) * progress
            let lockShackleCenterY = LockShackleCenter.start.y + (LockShackleCenter.end.y - LockShackleCenter.start.y) * progress
            lockShackleImageView.center = CGPoint(x: centerX + lockShackleCenterX, y: lockShackleCenterY)

            // Calculate the direction indicator center
            let directionIndicatorCenterX = DirectionIndicatorCenter.start.x + (DirectionIndicatorCenter.end.x - DirectionIndicatorCenter.start.x) * progress
            let directionIndicatorCenterY = DirectionIndicatorCenter.start.y + (DirectionIndicatorCenter.end.y - DirectionIndicatorCenter.start.y) * progress
            directionIndicatorImageView.center = CGPoint(x: centerX + directionIndicatorCenterX, y: directionIndicatorCenterY)

            // Adjust alpha based on progress
            directionIndicatorImageView.alpha = 1 - progress
        }
    }

    
    private func prepare() {
        bounds.size = BackgroundSize.start
        progress = 0
        isLocked = false
        addSubview(backgroundImageView)
        addSubview(lockShackleImageView)
        addSubview(lockBodyImageView)
        addSubview(directionIndicatorImageView)
        
//        layer.borderColor = UIColor.red.cgColor
//        layer.borderWidth = 2.0
    }
    
    func performLockedIconZoomAnimation(completion: @escaping () -> Void) {
        UIView.animate(withDuration: lockedIconZoomingAnimationDuration, delay: 0, options: .curveEaseIn, animations: {
        }, completion: nil)
        UIView.animate(withDuration: lockedIconZoomingAnimationDuration, delay: lockedIconZoomingAnimationDuration, options: [.curveEaseOut, .beginFromCurrentState], animations: {
        }) { (_) in
            completion()
        }
    }
    
}

extension LockView {
    
    static let lockedLockSize = CGSize(width: max(shackleImage.size.width, lockBodyImage.size.width), height: shackleImage.size.height + lockBodyImage.size.height + ShackleBottomMargin.end)
    static let verticalDistance: CGFloat = 50
    
    enum BackgroundOrigin {
        static let start = CGPoint(x: 0, y: 0)
        static let end = CGPoint(x: 0, y: start.y - verticalDistance)
    }
    
    enum BackgroundSize {
        static let start = CGSize(width: backgroundImage.size.width, height: 150)
        static let end = backgroundImage.size
    }
    
    enum DirectionIndicatorTopMargin {
        static let start: CGFloat = 20
        static let end: CGFloat = 8
    }
    
    enum ShackleBottomMargin {
        static let start: CGFloat = -1
        static let end: CGFloat = -5
    }
    
    enum LockBodyCenter {
        static let start = CGPoint(x: BackgroundSize.start.width / 2, y: BackgroundSize.start.height / 2 - 20)
        static let end = CGPoint(x: BackgroundSize.end.width / 2, y: BackgroundSize.end.height - (BackgroundSize.end.height - lockedLockSize.height) / 2 - lockBodyImage.size.height / 2 - verticalDistance)
    }
    
    enum LockShackleCenter {
        static let start = CGPoint(x: BackgroundSize.start.width / 2, y: LockBodyCenter.start.y - shackleImage.size.height / 2 - lockBodyImage.size.height / 2 - ShackleBottomMargin.start)
        static let end = CGPoint(x: BackgroundSize.end.width / 2, y: (BackgroundSize.end.height - lockedLockSize.height) / 2 + shackleImage.size.height / 2 - verticalDistance)
    }
    
    enum DirectionIndicatorCenter {
        static let start = CGPoint(x: BackgroundSize.start.width / 2, y: LockBodyCenter.start.y + DirectionIndicatorTopMargin.start + directionIndicationImage.size.height / 2)
        static let end = CGPoint(x: BackgroundSize.end.width / 2, y: LockBodyCenter.end.y + DirectionIndicatorTopMargin.end + directionIndicationImage.size.height / 2)
    }
}
