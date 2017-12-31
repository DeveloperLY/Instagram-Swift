//
//  LYPostCell.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYPostCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
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
        
        let pictureWidth = LYScreenW - 20
        
        // 约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[avatar(30)]-10-[picture(\(pictureWidth))]-5-[like(30)]", options: [], metrics: nil, views: ["avatar": avatarImageView, "picture": pictureImageView, "like": likeButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[username]", options: [], metrics: nil, views: ["username": usernameButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[picture]-5-[comment(30)]", options: [], metrics: nil, views: ["picture": pictureImageView, "comment": commentButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-15-[date]", options: [], metrics: nil, views: ["date": dateLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[like]-5-[title]-5-|", options: [], metrics: nil, views: ["like": likeButton, "title": titleLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[picture]-5-[more(30)]", options: [], metrics: nil, views: ["picture": pictureImageView, "more": moreButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[picture]-10-[likes]", options: [], metrics: nil, views: ["picture": pictureImageView, "likes": likeLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[avatar(30)]-10-[username]", options: [], metrics: nil, views: ["avatar": avatarImageView, "username": usernameButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[picture]-0-|", options: [], metrics: nil, views: ["picture": pictureImageView]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-15-[like(30)]-10-[likes]-20-[comment(30)]", options: [], metrics: nil, views: ["like": likeButton, "likes": likeLabel, "comment": commentButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[more(30)]-15-|", options: [], metrics: nil, views: ["more": moreButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-15-[title]-15-|", options: [], metrics: nil, views: ["title": titleLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[date]-10-|", options: [], metrics: nil, views: ["date": dateLabel]))
        
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
                }
            })
            
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
