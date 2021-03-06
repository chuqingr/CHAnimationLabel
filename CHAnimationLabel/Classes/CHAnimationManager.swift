//
//  CHAnimationManager.swift
//  AnimationLabelDemo
//
//  Created by 灰谷iMac on 2018/8/3.
//  Copyright © 2018年 灰谷iMac. All rights reserved.
//

import UIKit

class CHAnimationManager: NSObject {

    var duration: TimeInterval = 2
    weak var label:CHAnimationLabel? {
        didSet {
            guard let text = label?.text else { return }
            setAnimetion(text: text)
        }
    }
    /// 私有属性
    private(set) var animationType: CHAnimationType
    private var displayLink: CADisplayLink?
    private var beginTime: CFTimeInterval?
    private var endTime: CFTimeInterval?
    private var attributedString: NSMutableAttributedString?
    private var characterAnimationDuration: [TimeInterval]?
    private var characterAnimationDelay: [TimeInterval]?
    private var completion: (() -> Void)?
    private var isAnimating: Bool = false

    private var counter:UILabelCounter!
    private var progress:TimeInterval!
    private var lastUpdate:TimeInterval!
    private var totalTime:TimeInterval!
    var startingValue:CGFloat!
    var destinationValue:CGFloat!

    func startAnimation(_ completion:(() -> Void)?) {
        guard let label = label else {
            return
        }

        setDisplayLine()
        label.layer.removeAllAnimations()

        if !isAnimating {
            self.completion = completion
            beginTime = CACurrentMediaTime()
            endTime = duration + beginTime!
            displayLink?.isPaused = false
        }
        isAnimating = true
    }

    func startCounterAnimation(_ completion:(() -> Void)?) {
        guard let label = label else {
            return
        }
        
        progress = 0
        totalTime = duration
        if totalTime == 0 {
            setText(value: destinationValue)
            return
        }
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

        setDisplayLineCounter()
        label.layer.removeAllAnimations()
        if !isAnimating {
            self.completion = completion
            beginTime = CACurrentMediaTime()
            displayLink?.isPaused = false
        }
        isAnimating = true
    }
    

    // MARK: - Init
    convenience init(animationType: CHAnimationType, duration:TimeInterval) {
        self.init()
        self.animationType = animationType
        self.duration = duration
    }

    private override init() {
        animationType = .none
        super.init()
    }

    deinit {
        debugPrint("\(type(of: self)):deinit")
    }
}

extension CHAnimationManager {
    private func setDisplayLineCounter() {
        displayLink?.invalidate()
        displayLink = nil
        displayLink = CADisplayLink(target: self, selector: #selector(updateValue))
        displayLink?.frameInterval = 2
        displayLink?.add(to: RunLoop.main, forMode: .commonModes)
    }

}

extension CHAnimationManager {
    private func setDisplayLine() {
        displayLink?.invalidate()
        displayLink = nil
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: RunLoop.main, forMode: .commonModes)
    }

    private func setAnimetion(text:String) {
        characterAnimationDelay?.removeAll()
        characterAnimationDuration?.removeAll()

        guard let label = label else {
            return
        }

        let tempAttributedString = NSMutableAttributedString(string: text)
        var durationArray = [TimeInterval]()
        var delayArray = [TimeInterval]()

        switch animationType {
        case .typewriter:
            tempAttributedString.addAttribute(.baselineOffset, value: -label.font.lineHeight, range: NSRange(location: 0, length: tempAttributedString.length))
            let displayInterval = duration / TimeInterval(tempAttributedString.length)
            for index in 0..<tempAttributedString.length {
                durationArray.append(displayInterval)
                delayArray.append(TimeInterval(index) * displayInterval)
            }
        case .shine:
            tempAttributedString.addAttribute(.foregroundColor, value: label.textColor.withAlphaComponent(0), range: NSRange(location: 0, length: tempAttributedString.length))
            for index in 0..<tempAttributedString.length {
                delayArray.append(TimeInterval(arc4random_uniform(UInt32(duration) / 2 * 100) / 100))
                let remain = duration - Double(delayArray[index])
                durationArray.append(TimeInterval(arc4random_uniform(UInt32(remain) * 100) / 100))
            }
        case .fade:
            tempAttributedString.addAttribute(.foregroundColor, value: label.textColor.withAlphaComponent(0), range: NSRange(location: 0, length: tempAttributedString.length))
            let displayInterval = duration / TimeInterval(tempAttributedString.length)
            for index in 0..<tempAttributedString.length  {
                delayArray.append(TimeInterval(index) * displayInterval)
                durationArray.append(duration - delayArray[index])
            }
        default:
            break
        }

        attributedString = tempAttributedString
        characterAnimationDuration = durationArray
        characterAnimationDelay = delayArray
        label.attributedText = attributedString
    }
}

extension CHAnimationManager {
    @objc private func update() {
        guard let endTime = endTime else {
            return
        }
        guard let label = label else {
            return
        }

        let now = CACurrentMediaTime()
        label.attributedText = transform(currentTime: now)
        if now >= endTime {
            displayLink?.isPaused = true
            displayLink?.invalidate()
            displayLink = nil
            isAnimating = false
            if let completion = completion {
                completion()
            }
        }
    }

    private func transform(currentTime: CFTimeInterval) -> NSAttributedString? {
        guard let beginTime = beginTime else {
            return nil
        }
        guard let attributedString = attributedString else {
            return nil
        }

        switch animationType {
        case .typewriter:
            guard let durationArray = characterAnimationDuration else {
                return nil
            }
            guard let delayArray = characterAnimationDelay else {
                return nil
            }
            for index in 0..<attributedString.length {
                if CharacterSet.whitespacesAndNewlines.contains(attributedString.string[String.Index(encodedOffset: index)].unicodeScalars.first!) {
                    continue
                }
                attributedString.enumerateAttribute(.baselineOffset, in: NSRange(location: index, length: 1), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
                    var percent = (CGFloat(currentTime - beginTime) - CGFloat(delayArray[index])) / CGFloat(durationArray[index])
                    percent = fmax(0.0, percent)
                    percent = fmin(1.0, percent)
                    attributedString.addAttribute(.baselineOffset, value: (percent - 1) * label!.font.lineHeight, range: range)
                }
            }
        case .shine:

            guard let durationArray = characterAnimationDuration else {
                return nil
            }
            guard let delayArray = characterAnimationDelay else {
                return nil
            }
            for index in 0..<attributedString.length {
                if CharacterSet.whitespacesAndNewlines.contains(attributedString.string[String.Index(encodedOffset: index)].unicodeScalars.first!) {
                    continue
                }
                attributedString.enumerateAttribute(.foregroundColor, in: NSRange(location: index, length: 1), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
                    guard let color = value as? UIColor else {
                        return
                    }
                    let alpha = color.cgColor.alpha
                    let shouldUpdate: Bool = (alpha > 0 && alpha < 1) || Float(currentTime - beginTime) >= Float(delayArray[index])
                    if !shouldUpdate {
                        return
                    }
                    let percent = (CGFloat(currentTime - beginTime) - CGFloat(delayArray[index])) / CGFloat(durationArray[index])
                    attributedString.addAttribute(.foregroundColor, value: label!.textColor.withAlphaComponent(percent), range: range)
                }
            }
        case .fade:
            guard let durationArray = characterAnimationDuration else {
                return nil
            }
            guard let delayArray = characterAnimationDelay else {
                return nil
            }
            for index in 0..<attributedString.length {
                if CharacterSet.whitespacesAndNewlines.contains(attributedString.string[String.Index(encodedOffset: index)].unicodeScalars.first!) {
                    continue
                }
                attributedString.enumerateAttribute(.foregroundColor, in: NSRange(location: index, length: 1), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
                    guard let color = value as? UIColor else {
                        return
                    }
                    let alpha = color.cgColor.alpha
                    let shouldUpdate: Bool = (alpha > 0 && alpha < 1) || Float(currentTime - beginTime) >= Float(delayArray[index])
                    if !shouldUpdate {
                        return
                    }
                    let percent = (CGFloat(currentTime - beginTime) - CGFloat(delayArray[index])) / CGFloat(durationArray[index])
                    attributedString.addAttribute(.foregroundColor, value: label!.textColor.withAlphaComponent(percent), range: range)
                }
            }

        default:
            break
        }
        return attributedString
    }
}

extension CHAnimationManager {
    @objc private func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now

        if progress >= totalTime {
            displayLink?.isPaused = true
            displayLink?.invalidate()
            displayLink = nil
            progress = totalTime
        }

        setText(value: currentValue())

        if progress == totalTime {
            isAnimating = false
            if let completion = completion {
                completion()
            }
        }
    }

    private func setText(value:CGFloat) {
        guard let format = label?.format else { return }
        guard let label = label else { return }
        /// 正则匹配
        if NSPredicate(format: "SELF MATCHES %@", "%(.*)i").evaluate(with: format) || NSPredicate(format: "SELF MATCHES %@", "%(.*)d").evaluate(with: format) {
            label.text = String(format: format, Int(value))
        }else {
            label.text = String(format: format, value)
        }
    }

    private func currentValue() -> CGFloat {
        if progress >= totalTime {
            return destinationValue
        }
        let percent = progress / totalTime
        let updateValue = counter.update(t: CGFloat(percent))
        return startingValue + (updateValue * (destinationValue - startingValue))
    }
}
