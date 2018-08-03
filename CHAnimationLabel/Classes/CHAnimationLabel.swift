//
//  CHAnimationLabel.swift
//  AnimationLabelDemo
//
//  Created by 灰谷iMac on 2018/8/3.
//  Copyright © 2018年 灰谷iMac. All rights reserved.
//


import UIKit

/// 动画类型，枚举
public enum CHAnimationType {
    /// 无
    case none
    /// 打字机效果
    case typewriter
    /// 左右闪 发光
    case shine
    /// 淡入
    case fade
}


open class CHAnimationLabel: UILabel {

    /// 公开属性
    open var animationType = CHAnimationType.none {
        didSet {
            animator = CHAnimationManager(animationType: animationType, duration: duration)
            animator?.label = self
        }
    }

    override open var text: String? {
        didSet {
            animator?.label = self
        }
    }

    /// 私有属性
    private(set) var duration: TimeInterval = 4.0
    private var animator: CHAnimationManager?

    open func startAnimation(duration: TimeInterval, nextText: String? = nil,_ completion:(() -> Void)?) {
        guard let animator = animator else {
            return
        }
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

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
