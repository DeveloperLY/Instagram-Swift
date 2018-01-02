//
//  LYNewsCell.swift
//  Instagram-Swift
//
//  Created by LiuY on 2018/1/2.
//  Copyright © 2018年 DeveloperLY. All rights reserved.
//

import UIKit

class LYNewsCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 约束
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[ava(30)]-10-[username]-7-[info]-10-[date]", options: [], metrics: nil, views: ["avatar": avatarImageView, "username": usernameButton, "info": infoLabel, "date": dateLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[avatar(30)]-10-|", options: [], metrics: nil, views: ["avatar": avatarImageView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[username(30)]", options: [], metrics: nil, views: ["username": usernameButton]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[info(30)]", options: [], metrics: nil, views: ["info": infoLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(30)]", options: [], metrics: nil, views: ["date": dateLabel]))
        
        // 头像变圆
        self.avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        self.avatarImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
