//
//  LYRegisterViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/28.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYRegisterViewController: UIViewController {
    
    // 用户头像
    @IBOutlet weak var avatarImageView: UIImageView!
    
    // 用户名、密码、重复密码、电子邮箱
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // 姓名、简介、网站
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var webTextField: UITextField!
    
    // 注册、取消按钮关联
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // 设置滚动视图的高度
    var scrollViewHeight: CGFloat = 0.0
    
    
    // 获取虚拟键盘的大小
    var keyboardRect: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    // MARK: - Private Methods
    private func setUpUI() -> Void {
        let avatarImageTap = UITapGestureRecognizer(target: self, action: #selector(avatarImageTap(_:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(avatarImageTap)
        // 设置头像为圆形
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width * 0.5
        avatarImageView.clipsToBounds = true
    }
    
    private func selectImage() -> Void {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    // MARK: - Event/Touch
    @IBAction func registerButtonDidClick(_ sender: UIButton) {
        // 隐藏keyboard
        self.view.endEditing(true)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty || repeatPasswordTextField.text!.isEmpty || emailTextField.text!.isEmpty || fullnameTextField.text!.isEmpty || bioTextField.text!.isEmpty || webTextField.text!.isEmpty {
            // 弹出对话框提示用户
            let alert = UIAlertController(title: "请注意", message: "请填写好所有的信息内容", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if passwordTextField.text != repeatPasswordTextField.text {
            // 弹出对话框提示用户
            let alert = UIAlertController(title: "请注意", message: "两次输入的密码不一致", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if !LYUitils.validateEmail(email: emailTextField.text!) {
            LYProgressHUD.showError("请输入正确的邮箱")
            return
        }
        
        if !LYUitils.validateWeb(web: webTextField.text!) {
            LYProgressHUD.showError("请输入正确的网址")
            return
        }
        
        // 将用户输入的信息提交到服务器
        let user = AVUser()
        user.username = usernameTextField.text
        user.email = emailTextField.text
        user.password = passwordTextField.text
        user["fullname"] = fullnameTextField.text
        user["bio"] = bioTextField.text
        user["web"] = webTextField.text
        user["gender"] = ""
        
        // 转换头像数据并发送到服务器
        let avatarData = avatarImageView.image!.jpegData(compressionQuality: 0.5)
        let avatarFile = AVFile(data: avatarData!, name: "avatar.jpg")
        user["avatar"] = avatarFile
        
        LYProgressHUD.show("正在注册...")
        // 提交数据
        user.signUpInBackground { (isSuccess, error) in
            if isSuccess {
                LYProgressHUD.showSuccess("注册成功！")
                
                AVUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (user: AVUser?, error: Error?) in
                    if let user = user {
                        // 记住登录的用户
                        UserDefaults.standard.set(user.username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        
                        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.login()
                    }
                })
                
            } else {
                LYProgressHUD.showError(error?.localizedDescription ?? "注册失败！")
                print(error?.localizedDescription ?? "用户注册失败！")
            }
        }
    
    }
    
    @IBAction func cancelButtonDidClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func avatarImageTap(_ recognizer: UITapGestureRecognizer) -> Void {
        selectImage()
    }
    

}

// MARK: - UIImagePickerControllerDelegate
extension LYRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 用户选择了图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        avatarImageView.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // 用户取消选择图片
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension LYRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if usernameTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            repeatPasswordTextField.becomeFirstResponder()
        } else if repeatPasswordTextField.isFirstResponder {
            emailTextField.becomeFirstResponder()
        } else if emailTextField.isFirstResponder {
            fullnameTextField.becomeFirstResponder()
        } else if fullnameTextField.isFirstResponder {
            bioTextField.becomeFirstResponder()
        } else if bioTextField.isFirstResponder {
            webTextField.becomeFirstResponder()
        } else {
            webTextField.resignFirstResponder()
        }
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
