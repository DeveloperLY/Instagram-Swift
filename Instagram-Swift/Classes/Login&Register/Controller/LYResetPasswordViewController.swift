//
//  LYResetPasswordViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/28.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTestField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 添加手势
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(_:)))
        self.view.addGestureRecognizer(hideTap)
    }
    
    // MARK: - Event/Touch
    @IBAction func resetButtonDidClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if emailTestField.text!.isEmpty {
            // 弹出对话框提示用户
            let alert = UIAlertController(title: "请注意", message: "电子邮箱不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        AVUser.requestPasswordResetForEmail(inBackground: emailTestField.text!) { (isSuccess, error) in
            if isSuccess {
                let alert = UIAlertController(title: "请注意", message: "重置密码链接已经发送到您的电子邮箱！", preferredStyle: .alert)
                let ok = UIAlertAction(title: "好的", style: .cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription ?? "重置密码链接发送失败！")
            }
        }
    }
    
    @IBAction func cancelButtonDidClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboardTap(_ recognizer: UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
    }
}
