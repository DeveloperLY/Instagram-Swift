//
//  LYEditInfoViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/29.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYEditInfoViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var webTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    
    // PickerView 和 PickerData
    var genderPicker: UIPickerView!
    let genders = ["男", "女"]
    
    var keyboardRect = CGRect()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // 布局
        alignment()
        
        // 加载信息
        information()
        
        // 创建pickerView
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTextField.inputView = genderPicker
        
        // 头像选择手势
        let avatarImageTap = UITapGestureRecognizer(target: self, action: #selector(avatarImageTap(_:)))
        avatarImageView.addGestureRecognizer(avatarImageTap)
    }
    
    // 界面布局
    private func alignment() -> Void {
        let width = self.view.frame.width
        
        avatarImageView.frame = CGRect(x: width - 68.0 - 10.0, y: 15.0, width: 68.0, height: 68.0)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        fullnameTextField.frame = CGRect(x: 10.0, y: avatarImageView.frame.origin.y, width: width - avatarImageView.frame.width - 30.0, height: 30.0)
        
        usernameTextField.frame = CGRect(x: 10.0, y: fullnameTextField.frame.origin.y + 40.0, width: width - avatarImageView.frame.width - 30.0, height: 30.0)
        
        webTextField.frame = CGRect(x: 10.0, y: usernameTextField.frame.origin.y + 40.0, width: width - 20.0, height: 30.0)
        
        bioTextView.frame = CGRect(x: 10.0, y: webTextField.frame.origin.y + 40.0, width: width - 20.0, height: 60.0)
        // 添加边框
        bioTextView.layer.borderWidth = 1.0
        bioTextView.layer.borderColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0).cgColor
        // 设置圆角
        bioTextView.layer.cornerRadius = bioTextView.frame.width / 50.0
        bioTextView.clipsToBounds = true
        
        titleLabel.frame = CGRect(x: 10.0, y: bioTextView.frame.origin.y + 100.0, width: width - 20.0, height: 30.0)
        
        emailTextField.frame = CGRect(x: 10.0, y: titleLabel.frame.origin.y + 40.0, width: width - 20.0, height: 30.0)
        
        mobileTextField.frame = CGRect(x: 10.0, y: emailTextField.frame.origin.y + 40.0, width: width - 20.0, height: 30.0)
        
        genderTextField.frame = CGRect(x: 10.0, y: mobileTextField.frame.origin.y + 40.0, width: width - 20.0, height: 30.0)
        
    }
    
    // 获取用户信息
    private func information() -> Void {
        let avatar = AVUser.current()?.object(forKey: "avatar") as! AVFile
        avatar.getDataInBackground { (data: Data?, error: Error?) in
            if data == nil {
                print(error?.localizedDescription ?? "头像信息获取失败")
            } else {
                self.avatarImageView.image = UIImage(data: data!)
            }
        }
        
        usernameTextField.text = AVUser.current()?.username
        fullnameTextField.text = AVUser.current()?.object(forKey: "fullname") as? String
        webTextField.text = AVUser.current()?.object(forKey: "web") as? String
        bioTextView.text = AVUser.current()?.object(forKey: "bio") as? String
        
        emailTextField.text = AVUser.current()?.email
        mobileTextField.text = AVUser.current()?.mobilePhoneNumber
        genderTextField.text = AVUser.current()?.object(forKey: "gender") as? String
    }
    
    // 消息警告
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Event/Touch
    @IBAction func saveButtonDidClick(_ sender: UIBarButtonItem) {
        if !LYUitils.validateWeb(web: webTextField.text!) {
            alert(error: "错误的网页链接", message: "请输入正确的网址")
            return
        }
        
        if !LYUitils.validateEmail(email: emailTextField.text!) {
            alert(error: "错误的Email地址", message: "请输入正确的电子邮件地址")
            return
        }
        
        if !LYUitils.validateMobilePhoneNumber(mobilePhoneNumber: mobileTextField.text!) {
            alert(error: "错误的手机号码", message: "请输入正确的手机号码")
            return
        }
        
        // 保存Field信息到服务器中
        let user = AVUser.current()
        user?.username = usernameTextField.text
        user?.email = emailTextField.text?.lowercased()
        user?["fullname"] = fullnameTextField.text
        user?["web"] = webTextField.text?.lowercased()
        user?["bio"] = bioTextView.text
        
        user?.mobilePhoneNumber = (mobileTextField.text?.isEmpty)! ? "" : mobileTextField.text!
        
        user?["gender"] = (genderTextField.text?.isEmpty)! ? "" : genderTextField.text!
        
        let avatarData = UIImageJPEGRepresentation(avatarImageView.image!, 0.5)
        let avatarFile = AVFile(name: "avatar.jpg", data: avatarData!)
        user?["avatar"] = avatarFile
        
        LYProgressHUD.show("正在保存...")
        user?.saveInBackground({ (isSuccess: Bool, error: Error?) in
            if isSuccess {
                LYProgressHUD.showSuccess("信息修改成功！")
                // 隐藏键盘
                self.view.endEditing(true)
                
                // 退出
                self.dismiss(animated: true, completion: nil)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
            } else {
                LYProgressHUD.showError("信息修改失败！")
                print(error?.localizedDescription ?? "修改用户信息失败")
            }
        })
    }
    
    @IBAction func cancelDidClick(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func avatarImageTap(_ recognizer: UITapGestureRecognizer) -> Void {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension LYEditInfoViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genders[row]
        self.view.endEditing(true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension LYEditInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

// MARK: - UITextFieldDelegate
extension LYEditInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if fullnameTextField.isFirstResponder {
            usernameTextField.becomeFirstResponder()
        } else if usernameTextField.isFirstResponder {
            webTextField.becomeFirstResponder()
        } else if webTextField.isFirstResponder {
            bioTextView.becomeFirstResponder()
        } else if bioTextView.isFirstResponder {
            emailTextField.becomeFirstResponder()
        } else if emailTextField.isFirstResponder {
            mobileTextField.becomeFirstResponder()
        }
        return true
    }
}
