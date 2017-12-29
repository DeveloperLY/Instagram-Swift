//
//  LYHomeHeaderView.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/29.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYHomeHeaderView: UICollectionReusableView {
    
    // 用户头像
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullnameLabel: UILabel!
    
    @IBOutlet weak var webTextView: UITextView!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    
    
    @IBOutlet weak var posts: UILabel!
    
    @IBOutlet weak var followers: UILabel!
    
    @IBOutlet weak var followings: UILabel!
    
    @IBOutlet weak var editHomeButton: UIButton!
    
    
    @IBOutlet weak var followButton: UIButton!
    
    
    @IBAction func followButtonDidTouch(_ sender: UIButton) {
        let title = followButton.title(for: .normal)
        
        // 当前访客对象
        let user = guestArray.last
        
        if title == "关 注" {
            guard user != nil else {
                return
            }
            
            AVUser.current()?.follow((user?.objectId)!, andCallback: { (isSuccess: Bool, error: Error?) in
                if isSuccess {
                    self.followButton.setTitle("√ 已关注", for: .normal)
                    self.followButton.backgroundColor = .green
                } else {
                    print(error?.localizedDescription ?? "follow 失败...")
                }
            })
        } else {
            guard user != nil else {
                return
            }
            
            AVUser.current()?.unfollow((user?.objectId)!, andCallback: { (isSuccess: Bool, error: Error?) in
                if isSuccess {
                    self.followButton.setTitle("关 注", for: .normal)
                    self.followButton.backgroundColor = .lightGray
                } else {
                    print(error?.localizedDescription ?? "unfollow 失败...")
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 设置头像圆形
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width * 0.5
        avatarImageView.clipsToBounds = true
    }

}
