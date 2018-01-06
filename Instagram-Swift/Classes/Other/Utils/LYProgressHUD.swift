//
//  LYProgressHUD.swift
//  Instagram-Swift
//
//  Created by LiuY on 2018/1/5.
//  Copyright © 2018年 DeveloperLY. All rights reserved.
//

import UIKit
import SVProgressHUD

class LYProgressHUD: NSObject {
    class func enable() -> Void {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: LYNavigatorHeight))
    }
    
    class func show() -> Void {
        SVProgressHUD.show()
    }
    
    class func show(_ status: String) -> Void {
        SVProgressHUD.show(withStatus: status)
    }
    
    class func showProgress(progress: CGFloat) -> Void {
        SVProgressHUD.showProgress(Float(progress))
    }
    
    class func showProgress(progress: CGFloat, status: String) -> Void {
        SVProgressHUD.showProgress(Float(progress), status: status)
    }
    
    class func showInfo(_ status: String) -> Void {
        SVProgressHUD.showInfo(withStatus: status)
    }
    
    class func showSuccess(_ status: String) -> Void {
        SVProgressHUD.showSuccess(withStatus: status)
    }
    
    class func showError(_ status: String) -> Void {
        SVProgressHUD.showError(withStatus: status)
    }
    
    class func dismiss() -> Void {
        SVProgressHUD.dismiss()
    }
}
