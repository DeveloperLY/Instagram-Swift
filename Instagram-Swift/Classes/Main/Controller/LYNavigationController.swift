//
//  LYNavigationController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit

class LYNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 导航栏中Title的颜色设置
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        // 导航栏中按钮的颜色
        self.navigationBar.tintColor = .white
        // 导航栏的背景色
        self.navigationBar.barTintColor = UIColor(red: 18.0 / 255.0, green: 86.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
        // 不允许透明
        self.navigationBar.isTranslucent = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}
