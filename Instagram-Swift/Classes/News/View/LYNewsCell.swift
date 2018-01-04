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
        
        avatarImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(self.contentView).offset(10.0)
            make.bottom.equalTo(self.contentView).offset(-10.0)
            make.width.height.equalTo(30.0)
        }
        
        usernameButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.avatarImageView.snp.right).offset(10.0)
            make.centerY.equalTo(self.avatarImageView)
            make.height.equalTo(30.0)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.usernameButton)
            make.left.equalTo(self.usernameButton.snp.right).offset(7.0)
            make.height.equalTo(30.0)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.infoLabel.snp.right).offset(10.0)
            make.centerY.equalTo(self.infoLabel)
            make.height.equalTo(30.0)
        }
        
        // 头像变圆
        self.avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        self.avatarImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
