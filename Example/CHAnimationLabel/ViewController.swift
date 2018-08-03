//
//  ViewController.swift
//  CHAnimationLabel
//
//  Created by 杨胜浩 on 08/03/2018.
//  Copyright (c) 2018 杨胜浩. All rights reserved.
//

import UIKit
import CHAnimationLabel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    private func initUI() {
        let label = CHAnimationLabel(frame: CGRect(x: 33, y: 66, width: 199, height: 133))
        label.text = "哈哈哈哈哈"
        label.font = UIFont.systemFont(ofSize: 15)
        label.animationType = .fade
        label.textColor = .black
        view.addSubview(label)
        label.startAnimation(duration: 2, nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

