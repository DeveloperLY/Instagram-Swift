//
//  LYUploadViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/30.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import SnapKit
import AVOSCloud

class LYUploadViewController: UIViewController {
    
    @IBOutlet weak var imageContentView: UIView!
    
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var publishButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 布局UI
        alignment()
        
        // 图片选择手势
        let pictureImageTap = UITapGestureRecognizer(target: self, action: #selector(pictureImageTap(_:)))
        pictureImageView.addGestureRecognizer(pictureImageTap)
        
        // 让UI回到初始状态
        pictureImageView.image = UIImage(named: "pbg.jpg")
        titleTextView.text = ""
    }
    
    // MARK: - Pivate Methods
    private func alignment() -> Void {
        imageContentView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(15.0)
            make.top.equalTo(self.view).offset(LYNavigatorBarHeight + 35.0)
            make.width.height.equalTo(LYScreenW / 4.5)
        }
        
        pictureImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(15.0)
            make.top.equalTo(self.view).offset(LYNavigatorBarHeight + 35.0)
            make.width.height.equalTo(LYScreenW / 4.5)
        }
        
        titleTextView.snp.makeConstraints { (make) in
            make.left.equalTo(imageContentView.snp.right).offset(10.0)
            make.top.equalTo(imageContentView)
            make.right.equalTo(self.view).offset(-10.0)
            make.bottom.equalTo(imageContentView)
        }
        
        removeButton.snp.makeConstraints { (make) in
            make.left.width.equalTo(self.imageContentView)
            make.top.equalTo(self.imageContentView.snp.bottom)
            make.height.equalTo(30.0)
        }
        
        publishButton.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-(LYScreenW / 8))
            make.height.equalTo(LYScreenW / 8)
        }
    }
    
    // MARK: - Event/Touch
    @objc func pictureImageTap(_ recognizer: UITapGestureRecognizer) -> Void {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func removeButtonDidClick(_ sender: UIButton) {
        self.viewDidLoad()
    }
    
    
    @IBAction func publishButtonDidClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["avatar"] = AVUser.current()?.value(forKey: "avatar") as! AVFile
        
        if let username = AVUser.current()?.username {
            object["puuid"] = "\(username)-\(NSUUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())"
        }
        
        object["title"] = titleTextView.text.isEmpty ? "" : titleTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // 图片数据
        let imageData = UIImageJPEGRepresentation(pictureImageView.image!, 0.5)
        let imageFile = AVFile(name: "post.jpg", data: imageData!)
        object["picture"] = imageFile
        
        // 提交服务器
        object.saveInBackground { (success: Bool, error: Error?) in
            if error == nil {
                // 发送通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                
                // 改变Tabar显示索引
                self.tabBarController?.selectedIndex = 0
                
                // reset
                self.viewDidLoad()
            }
        }
    }
    
    
}


// MARK: - UIImagePickerControllerDelegate
extension LYUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 用户选择了图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        pictureImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // 发布按钮状态
        publishButton.isEnabled = true
        publishButton.backgroundColor = UIColor(red: 52.0 / 255.0, green: 169.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        
        // 显示移除按钮
        removeButton.isHidden = false
        
        // 第二次单击放大图片
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomImageTap(_:)))
        pictureImageView.addGestureRecognizer(zoomTap)
    }
    
    // 用户取消选择图片
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 放大或缩小图片
    @objc func zoomImageTap(_ recognizer: UITapGestureRecognizer) -> Void {
        pictureImageView.snp.remakeConstraints { (make) in
            if pictureImageView.center == self.view.center {
                make.left.equalTo(self.view).offset(15.0)
                make.top.equalTo(self.view).offset(LYNavigatorBarHeight + 35.0)
                make.width.height.equalTo(LYScreenW / 4.5)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.backgroundColor = .white
                    self.imageContentView.alpha = 1
                    self.titleTextView.alpha = 1
                    self.publishButton.alpha = 1
                    self.removeButton.alpha = 1
                })
            } else {
                make.center.equalTo(self.view)
                make.width.height.equalTo(LYScreenW)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.backgroundColor = .black
                    self.imageContentView.alpha = 0
                    self.titleTextView.alpha = 0
                    self.publishButton.alpha = 0
                    self.removeButton.alpha = 0
                })
                
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutSubviews()
            self.view.setNeedsLayout()
            self.view.layoutSubviews()
        }
    }
}
