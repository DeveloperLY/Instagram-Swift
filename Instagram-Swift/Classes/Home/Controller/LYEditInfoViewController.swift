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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        
        setUpNotification()
        
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
        let height = self.view.frame.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
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
    
    private func setUpNotification() -> Void {
        // 监听键盘弹出和消失
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    // 校验Email的合法性
    private func validateEmail(email: String) -> Bool {
        let regex = "\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // 校验Web的合法性
    private func validateWeb(web: String) -> Bool {
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    // 校验手机号的合法性
    private func validateMobilePhoneNumber(mobilePhoneNumber: String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = mobilePhoneNumber.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
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
        if !validateWeb(web: webTextField.text!) {
            alert(error: "错误的网页链接", message: "请输入正确的网址")
            return
        }
        
        if !validateEmail(email: emailTextField.text!) {
            alert(error: "错误的Email地址", message: "请输入正确的电子邮件地址")
            return
        }
        
        if !validateMobilePhoneNumber(mobilePhoneNumber: mobileTextField.text!) {
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
        
        user?.saveInBackground({ (isSuccess: Bool, error: Error?) in
            if isSuccess {
                // 隐藏键盘
                self.view.endEditing(true)
                
                // 退出
                self.dismiss(animated: true, completion: nil)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
            } else {
                print(error?.localizedDescription ?? "修改用户信息失败")
            }
        })
    }
    
    @IBAction func cancelDidClick(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func showKeyboard(_ notification: Notification) -> Void {
        // 获取keyboard大小
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboardRect = rect.cgRectValue
        
        // 修改滚动视图高度
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.frame.height + self.keyboardRect.height / 2
        }
    }
    
    @objc func hideKeyboard(_ notification: Notification) -> Void {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = 0
        }
    }
    
    @objc func avatarImageTap(_ recognizer: UITapGestureRecognizer) -> Void {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
