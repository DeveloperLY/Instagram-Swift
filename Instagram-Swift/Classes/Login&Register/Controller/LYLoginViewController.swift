//
//  LYLoginViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/28.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYLoginViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nameLabel 字体
        nameLabel.font = UIFont(name: "Pacifico", size: 25.0)
    }
    
    // MARK: - Event/Touch
    @IBAction func loginButtonDidClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            // 弹出对话框提示用户
            let alert = UIAlertController(title: "请注意", message: "用户名和密码不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // 用户登录
        AVUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error == nil {
                // 登录成功
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            } else {
                print(error?.localizedDescription ?? "用户登录失败！")
            }
        }
        
    }
    
}

// MARK: - UITextFieldDelegate
extension LYLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if usernameTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
