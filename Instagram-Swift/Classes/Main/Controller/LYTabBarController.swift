//
//  LYTabBarController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit

class LYTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 每个Item的文字颜色为白色
        self.tabBar.tintColor = .white
        
        // 标签栏的背景色
        self.tabBar.barTintColor = UIColor(red: 37.0 / 255.0, green: 39.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0)
        
        self.tabBar.isTranslucent = false
    }

}
