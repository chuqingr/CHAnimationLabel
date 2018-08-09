# CHAnimationLabel

[![CI Status](https://img.shields.io/travis/杨胜浩/CHAnimationLabel.svg?style=flat)](https://travis-ci.org/杨胜浩/CHAnimationLabel)
[![Version](https://img.shields.io/cocoapods/v/CHAnimationLabel.svg?style=flat)](https://cocoapods.org/pods/CHAnimationLabel)
[![License](https://img.shields.io/cocoapods/l/CHAnimationLabel.svg?style=flat)](https://cocoapods.org/pods/CHAnimationLabel)
[![Platform](https://img.shields.io/cocoapods/p/CHAnimationLabel.svg?style=flat)](https://cocoapods.org/pods/CHAnimationLabel)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CHAnimationLabel is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CHAnimationLabel'
```

## use
#### animationType < .easeInOut
```swift
let label = CHAnimationLabel(frame: CGRect(x: 33, y: 66, width: 333, height: 133))
label.animationType = .typewriter
///label.animationType = .shine
///label.animationType = .count
label.text = "This is a label with animation effects"
label.textColor = .black
view.addSubview(label)
label.startAnimation(duration: 2, nil)
```
#### animationType >= .easeInOut
```swift
let label = CHAnimationLabel(frame: CGRect(x: 33, y: 66, width: 333, height: 133))
label.animationType = .easeInOut
///label.animationType = .easeIn
///...
label.text = "This is a label with animation effects"
label.textColor = .black
view.addSubview(label)
label.startCounterAnimation(frome: 0, to: 10000, with: 2) {
	debugPrint("do something")
}
```

## Author

杨胜浩, chuqingr@icloud.com

## License

CHAnimationLabel is available under the MIT license. See the LICENSE file for more info.
