//
//  LYRegisterViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/28.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import LeanCloud

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
    
    // 滚动视图
    @IBOutlet weak var scrollView: UIScrollView!
    
    // 注册、取消按钮关联
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // 设置滚动视图的高度
    var scrollViewHeight: CGFloat = 0.0
    
    
    @IBOutlet weak var scrollBottomConstraint: NSLayoutConstraint!
    
    
    // 获取虚拟键盘的大小
    var keyboardRect: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        setUpNotification()
        
        // 添加手势
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(_:)))
        self.view.addGestureRecognizer(hideTap)
    }
    
    // MARK: - Private Methods
    private func setUpUI() -> Void {
        // 设置 contentSize
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = self.view.frame.height
        
        let avatarImageTap = UITapGestureRecognizer(target: self, action: #selector(avatarImageTap(_:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(avatarImageTap)
        // 设置头像为圆形
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width * 0.5
        avatarImageView.clipsToBounds = true
        
        
    }
    
    private func setUpNotification() -> Void {
        // 监听键盘弹出和消失
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
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
        
        // 将用户输入的信息提交到服务器
        let user = LCUser()
        user.username = LCString((usernameTextField.text)!)
        user.email = LCString((emailTextField.text?.lowercased())!)
        user.password = LCString(passwordTextField.text!)
        user["fullname"] = LCString(fullnameTextField.text!)
        user["bio"] = LCString(bioTextField.text!)
        user["web"] = LCString(webTextField.text!)
        user["gender"] = LCString("")
        
        // 转换头像数据并发送到服务器
        let avatarData = UIImageJPEGRepresentation(avatarImageView.image!, 0.5)
        user["avatar"] = LCData(avatarData!)
        
        user.signUp { (result) in
            if result.isSuccess {
                print("用户注册成功！")
                
                // 记住登录的用户
                UserDefaults.standard.set(user.username?.jsonString, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            } else {
                print(result.error?.localizedDescription ?? "用户注册失败！")
            }
        }
    }
    
    @IBAction func cancelButtonDidClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showKeyboard(_ notification: Notification) -> Void {
        // 获取keyboard大小
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboardRect = rect.cgRectValue
        
        // 修改滚动视图高度
        UIView.animate(withDuration: 0.4) {
            self.scrollBottomConstraint.constant -= self.keyboardRect.size.height
            self.scrollView.contentSize.height = self.view.frame.height
        }
    }
    
    @objc func hideKeyboard(_ notification: Notification) -> Void {
        UIView.animate(withDuration: 0.4) {
            self.scrollBottomConstraint.constant = 0
        }
    }
    
    @objc func hideKeyboardTap(_ recognizer: UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
    }
    
    @objc func avatarImageTap(_ recognizer: UITapGestureRecognizer) -> Void {
        selectImage()
    }
    

}

// MARK: - UIImagePickerControllerDelegate
extension LYRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 用户选择了图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avatarImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // 用户取消选择图片
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
