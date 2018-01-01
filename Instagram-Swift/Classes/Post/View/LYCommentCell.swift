//
//  LYCommentCell.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import KILabel

class LYCommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var commentLabel: KILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-5-[username]-(-2)-[comment]-5-|",
            options: [], metrics: nil, views: ["username": usernameButton, "comment": commentLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-15-[date]",
            options: [], metrics: nil, views: ["date": dateLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[avatar(40)]",
            options: [], metrics: nil, views: ["avatar": avatarImageView]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[avatar(40)]-13-[comment]-20-|",
            options: [], metrics: nil, views: ["avatar": avatarImageView, "comment": commentLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[avatar]-13-[username]",
            options: [], metrics: nil, views: ["avatar": avatarImageView, "username": usernameButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[date]-10-|",
            options: [], metrics: nil, views: ["date": dateLabel]))
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
