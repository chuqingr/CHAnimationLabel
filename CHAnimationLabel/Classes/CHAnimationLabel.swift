//
//  CHAnimationLabel.swift
//  AnimationLabelDemo
//
//  Created by 灰谷iMac on 2018/8/3.
//  Copyright © 2018年 灰谷iMac. All rights reserved.
//


import UIKit

/// 动画类型，枚举
public enum CHAnimationType:Int {
    /// 无
    case none = 0
    /// 打字机效果
    case typewriter
    /// 左右闪 发光
    case shine
    /// 淡入
    case fade
    /// 计数
    case easeInOut = 5
    case easeIn
    case easeOut
    case linear
    case easeInBounce
    case easeOutBounce
}

/// 计数动画协议
protocol UILabelCounter {
    func update(t:CGFloat) -> CGFloat
}

/// rate
let counterRate:CGFloat = 3

open class UILabelCounterLinear: UILabelCounter {
    func update(t: CGFloat) -> CGFloat {
        return t
    }
}

open class UILabelCounterEaseIn: UILabelCounter {
    func update(t: CGFloat) -> CGFloat {
        return pow(t, counterRate)
    }
}

open class UILabelCounterEaseOut: UILabelCounter {
    func update(t: CGFloat) -> CGFloat {
        return 1.0-pow((1.0-t), counterRate)
    }
}

open class UILabelCounterEaseInOut: UILabelCounter {
    func update(t: CGFloat) -> CGFloat {
        let tempT = t * 2
        if tempT < 1 {
            return 0.5 * pow(tempT, counterRate)
        } else {
            return 0.5 * (2.0 - pow(2.0 - tempT, counterRate))
        }
    }
}

open class UILabelCounterEaseInBounce: UILabelCounter {
    func update(t: CGFloat) -> CGFloat {
        if t < 4.0 / 11.0 {
            return 1.0 - (pow(11.0 / 4.0, 2) * pow(t, 2)) - t
        }

        if t < 8.0 / 11.0 {
            return 1.0 - (3.0 / 4.0 + pow(11.0 / 4.0, 2) * pow(t - 6.0 / 11.0, 2)) - t
        }

        if t < 10.0 / 11.0 {
            return 1.0 - (15.0 / 16.0 + pow(11.0 / 4.0, 2) * pow(t - 9.0 / 11.0, 2)) - t
        }

        return 1.0 - (63.0 / 64.0 + pow(11.0 / 4.0, 2) * pow(t - 21.0 / 22.0, 2)) - t

    }
}

open class UILabelCounterEaseOutBounce: UILabelCounter {
    func update(t: CGFloat) -> CGFloat {
        if t < 4.0 / 11.0 {
            return pow(11.0 / 4.0, 2) * pow(t, 2);
        }
        if t < 8.0 / 11.0 {
            return 3.0 / 4.0 + pow(11.0 / 4.0, 2) * pow(t - 6.0 / 11.0, 2)
        }

        if t < 10.0 / 11.0 {
            return 15.0 / 16.0 + pow(11.0 / 4.0, 2) * pow(t - 9.0 / 11.0, 2)
        }
        return 63.0 / 64.0 + pow(11.0 / 4.0, 2) * pow(t - 21.0 / 22.0, 2)
    }
}

open class CHAnimationLabel: UILabel {

    /// 公开属性
    open var animationType = CHAnimationType.none {
        didSet {
            animator = CHAnimationManager(animationType: animationType, duration: duration)
            animator?.label = self
        }
    }
    open var format:String?

    override open var text: String? {
        didSet {
            animator?.label = self
        }
    }

    var progress:TimeInterval!
    var lastUpdate:TimeInterval!
    var totalTime:TimeInterval!
    /// 私有属性
    private(set) var duration: TimeInterval = 4.0
    private var startingValue:CGFloat!
    private var destinationValue:CGFloat!
    private var counter:UILabelCounter!
    private var animator: CHAnimationManager?

    open func startAnimation(duration: TimeInterval,
                             nextText: String? = nil,
                             _ completion:(() -> Void)?) {
        guard let animator = animator else { return }
        if text == nil && nextText == nil {
            return
        } else if nextText != nil {
            text = nextText
        }
        self.duration = duration
        animator.duration = duration
        animator.label = self
        animator.startAnimation(completion)
    }
//countFrom:(CGFloat)startValue to:(CGFloat)endValue withDuration:(NSTimeInterval)duration
    open func startCounterAnimation(frome startValue:CGFloat,
                    to endValue:CGFloat,
                    with duration:TimeInterval,
                    _ completion:(() -> Void)?) {
        guard let animator = animator else { return }

        startingValue = startValue
        destinationValue = endValue

        if duration == 0 {
            setText(value: endValue)
            return
        }

        if format == nil {
            self.format = "%.1f"
        }

        progress = 0
        totalTime = duration
        lastUpdate = Date.timeIntervalSinceReferenceDate

        switch animationType {
        case .linear:
            counter = UILabelCounterLinear()
        case .easeIn:
            counter = UILabelCounterEaseIn()
        case .easeOut:
            counter = UILabelCounterEaseOut()
        case .easeInOut:
            counter = UILabelCounterEaseInOut()
        case .easeOutBounce:
            counter = UILabelCounterEaseOutBounce()
        case .easeInBounce:
            counter = UILabelCounterEaseInBounce()
        default:
            break
        }

        self.duration = duration
        animator.label = self
        animator.startCounterAnimation(completion)
    }

    deinit {
        debugPrint("\(type(of: self)):deinit")
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setText(value:CGFloat) {
        /// 正则匹配
        if NSPredicate(format: "SELF MATCHES %@", "%(.*)i").evaluate(with: self.format) || NSPredicate(format: "SELF MATCHES %@", "%(.*)d").evaluate(with: self.format) {
            text = String(format: self.format!, Int(value))
        }else {
            text = String(format: self.format!, value)
        }
    }

    func currentValue() -> CGFloat {
        if progress >= totalTime {
            return destinationValue
        }
        let percent = progress / totalTime
        let updateVal = counter.update(t: CGFloat(percent))
        debugPrint("\(updateVal)")
        return startingValue + (updateVal * (destinationValue - startingValue))
    }

}
