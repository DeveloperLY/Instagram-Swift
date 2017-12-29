//
//  LYFollowersCell.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/29.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYFollowersCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    var user: AVUser!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 设置头像圆形
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width * 0.5
        avatarImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followButtonDidTouch(_ sender: UIButton) {
        let title = followButton.title(for: .normal)
        
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
    

}
