//
//  LYLoginViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/28.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import LeanCloud

class LYLoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTestField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 添加手势
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(_:)))
        self.view.addGestureRecognizer(hideTap)
    }
    
    // MARK: - Event/Touch
    @IBAction func loginButtonDidClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if usernameTextField.text!.isEmpty || passwordTestField.text!.isEmpty {
            // 弹出对话框提示用户
            let alert = UIAlertController(title: "请注意", message: "用户名和密码不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // 用户登录
        LCUser.logIn(username: usernameTextField.text!, password: passwordTestField.text!) { (result) in
            if result.error == nil {
                // 登录成功
                UserDefaults.standard.set(result.object?.username?.jsonString, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            } else {
                print(result.error?.localizedDescription ?? "用户登录失败！")
            }
        }
    }
    
    @objc func hideKeyboardTap(_ recognizer: UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
    }
    
}
