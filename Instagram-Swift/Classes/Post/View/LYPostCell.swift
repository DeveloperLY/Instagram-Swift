//
//  LYPostCell.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud
import ActiveLabel

class LYPostCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var titleLabel: ActiveLabel!
    @IBOutlet weak var puuidLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 布局约束
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        pictureImageView.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        likeLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        puuidLabel.translatesAutoresizingMaskIntoConstraints = false
        
        avatarImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(self.contentView).offset(10.0)
            make.height.width.equalTo(30.0)
        }
        
        usernameButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.avatarImageView.snp.right).offset(10.0)
            make.right.lessThanOrEqualTo(self.contentView.snp.centerX)
            make.centerY.equalTo(self.avatarImageView)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.usernameButton)
            make.right.equalTo(self.contentView).offset(-10.0)
        }
        
        pictureImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(10.0)
            make.left.right.equalTo(self.contentView)
            make.height.equalTo(LYScreenW - 20)
        }
        
        likeButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(15.0)
            make.top.equalTo(self.pictureImageView.snp.bottom).offset(5.0)
            make.width.height.equalTo(30.0)
        }
        
        likeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.likeButton.snp.right).offset(10.0)
            make.top.equalTo(self.pictureImageView.snp.bottom).offset(10)
        }
        
        commentButton.snp.makeConstraints { (make) in
            make.centerY.width.height.equalTo(self.likeButton)
            make.left.equalTo(self.likeLabel.snp.right).offset(20.0)
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.centerY.width.height.equalTo(self.commentButton)
            make.right.equalTo(self.contentView).offset(-15.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(15.0)
            make.top.equalTo(self.likeButton.snp.bottom).offset(5.0)
            make.right.equalTo(self.contentView).offset(-15.0)
            make.bottom.equalTo(self.contentView).offset(-5.0)
        }
        
        // 可以不设置
        puuidLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.pictureImageView)
        }
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        // 双击图片添加喜欢
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped(_:)))
        likeTap.numberOfTapsRequired = 2
        pictureImageView.addGestureRecognizer(likeTap)
    }
    
    // MARK: - Event/Touch
    @IBAction func likeButtonDidClick(_ sender: UIButton) {
        let isLike = sender.isSelected
        
        if !isLike {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.objectId
            object["to"] = puuidLabel.text
            object.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    self.likeButton.isSelected = true
                    
                    // 发送通知
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    // 点击喜爱按钮后添加消息通知
                    if self.usernameButton.titleLabel?.text != AVUser.current()?.username {
                        let newsObject = AVObject(className: "News")
                        newsObject["by"] = AVUser.current()?.username
                        newsObject["avatar"] = AVUser.current()?.object(forKey: "avatar") as! AVFile
                        newsObject["to"] = self.usernameButton.titleLabel?.text
                        newsObject["owner"] = self.usernameButton.titleLabel?.text
                        newsObject["puuid"] = self.puuidLabel.text
                        newsObject["type"] = "like"
                        newsObject["checked"] = "no"
                        newsObject.saveEventually()
                    }
                }
            })
        } else {
            let query = AVQuery(className: "Likes")
            query.whereKey("by", equalTo: AVUser.current()?.objectId ?? "")
            query.whereKey("to", equalTo: puuidLabel.text ?? "")
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                for object in objects! {
                    // 有记录就从服务器上删除
                    (object as AnyObject).deleteInBackground({ (success: Bool, error: Error?) in
                        if success {
                            self.likeButton.isSelected = false
                            
                            // 发送通知
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                            
                            // 点击喜爱按钮后删除消息通知
                            let newsQuery = AVQuery(className: "News")
                            newsQuery.whereKey("by", equalTo: AVUser.current()?.username ?? "")
                            newsQuery.whereKey("to", equalTo: self.usernameButton.titleLabel?.text ?? "")
                            newsQuery.whereKey("puuid", equalTo: self.puuidLabel.text ?? "")
                            newsQuery.whereKey("type", equalTo: "like")
                            
                            newsQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                                if error == nil {
                                    for object in objects! {
                                        (object as AnyObject).deleteEventually()
                                    }
                                }
                            })
                        }
                    })
                }
            })
        }
        
    }
    
    
    @objc func likeTapped(_ tapGestureRecognizer: UITapGestureRecognizer) -> Void {
        // 创建交换动画
        let likeImageView = UIImageView(image: UIImage(named: "unlike.png"))
        likeImageView.frame.size.width = pictureImageView.frame.width / 1.5
        likeImageView.frame.size.height = pictureImageView.frame.height / 1.5
        likeImageView.center = pictureImageView.center
        likeImageView.alpha = 0.8
        self.addSubview(likeImageView)
        
        // 动画
        UIView.animate(withDuration: 0.4) {
            likeImageView.alpha = 0
            likeImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        
        // 修改服务器数据
        if !likeButton.isSelected {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.objectId
            object["to"] = puuidLabel.text
            object.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    self.likeButton.isSelected = true
                    
                    // 发送通知
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    // 点击喜爱按钮后添加消息通知
                    if self.usernameButton.titleLabel?.text != AVUser.current()?.username {
                        let newsObject = AVObject(className: "News")
                        newsObject["by"] = AVUser.current()?.username
                        newsObject["avatar"] = AVUser.current()?.object(forKey: "avatar") as! AVFile
                        newsObject["to"] = self.usernameButton.titleLabel?.text
                        newsObject["owner"] = self.usernameButton.titleLabel?.text
                        newsObject["puuid"] = self.puuidLabel.text
                        newsObject["type"] = "like"
                        newsObject["checked"] = "no"
                        newsObject.saveEventually()
                    }
                }
            })
            
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
