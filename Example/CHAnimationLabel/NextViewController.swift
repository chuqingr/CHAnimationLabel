//
//  NextViewController.swift
//  CHAnimationLabel_Example
//
//  Created by 灰谷iMac on 2018/8/8.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import CHAnimationLabel

class NextViewController: UIViewController {


    private var label:CHAnimationLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    deinit {
        debugPrint("\(type(of: self)):deinit")
    }

    private func initUI() {
        view.backgroundColor = UIColor.white
        label = CHAnimationLabel(frame: CGRect(x: 33, y: 66, width: 199, height: 133))
        //        label.text = "这是一个有动画的label，让我们来看一看~"
        label.font = UIFont.systemFont(ofSize: 15)
        label.animationType = .easeInOut
        label.format = "%.2f"
        label.startCounterAnimation(frome: 0, to: 10000, with: 2) {
            debugPrint("完成了")
        }
        //        label.animationType = .typewriter
        //        label.animationType = .shine
        //        label.animationType = .count
        label.textColor = .black
        view.addSubview(label)
        //        label.startAnimation(duration: 2, nil)

        let btn = UIButton(frame: CGRect(x: 100 , y: 300, width: 100, height: 100))
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(click(btn:)), for: .touchUpInside)
        btn.backgroundColor = UIColor.orange
    }

    @objc func click(btn:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        label.startCounterAnimation(frome: 0, to: 10000, with: 2) {
            debugPrint("完成了")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
