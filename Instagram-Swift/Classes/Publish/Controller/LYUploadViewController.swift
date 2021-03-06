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
        
        // 默认状态下禁用 publishButton 按钮
        publishButton.isEnabled = false
        publishButton.backgroundColor = .lightGray
        
        // 隐藏移除按钮
        removeButton.isHidden = true
    }
    
    // MARK: - Pivate Methods
    private func alignment() -> Void {
        imageContentView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(15.0)
            make.top.equalTo(self.view).offset(15.0)
            make.width.height.equalTo(LYScreenW / 4.5)
        }
        
        pictureImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(15.0)
            make.top.equalTo(self.view).offset(15.0)
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
            make.left.right.bottom.equalTo(self.view)
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
        
        let uuid = NSUUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        
        if let username = AVUser.current()?.username {
            object["puuid"] = "\(username)-\(uuid)"
        }
        
        object["title"] = titleTextView.text.isEmpty ? "" : titleTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // 图片数据
        let imageData = pictureImageView.image!.jpegData(compressionQuality: 0.5)
        let imageFile = AVFile(data: imageData!, name: "post.jpg")
        object["picture"] = imageFile
        
        // 发送Hashtag到云端
        let words: [String] = titleTextView.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            // 定义正则表达式
            let pattern = "#[^#]+";
            let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
            let results = regular.matches(in: word, options: .reportProgress , range: NSMakeRange(0, word.count))
            
            //输出截取结果
            print("符合的结果有\(results.count)个")
            for result in results {
                word = (word as NSString).substring(with: result.range)
            }
            
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = AVObject(className: "Hashtags")
                if let username = AVUser.current()?.username {
                    hashtagObj["to"] = "\(username)-\(uuid)"
                }
                hashtagObj["by"] = AVUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = titleTextView.text
                hashtagObj.saveInBackground({ (success: Bool, error: Error?) in
                    if success {
                        print("hashtag \(word) 已经被创建。")
                    } else {
                        print(error?.localizedDescription ?? "提交Hashtag失败")
                    }
                })
            }
        }
        
        // 提交服务器
        LYProgressHUD.show("正在发布中...")
        object.saveInBackground { (success: Bool, error: Error?) in
            if error == nil {
                LYProgressHUD.showSuccess("发布成功！")
                // 发送通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                
                // 改变Tabar显示索引
                self.tabBarController?.selectedIndex = 0
                
                // reset
                self.viewDidLoad()
            } else {
                print(error?.localizedDescription ?? "帖子发布失败！")
                LYProgressHUD.showError("发布失败！")
            }
        }
    }
    
    
}


// MARK: - UIImagePickerControllerDelegate
extension LYUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 用户选择了图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        pictureImageView.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
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
            if pictureImageView.frame.width == LYScreenW {
                make.left.equalTo(self.view).offset(15.0)
                make.top.equalTo(self.view).offset(15.0)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
