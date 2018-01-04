//
//  LYCommentCell.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import ActiveLabel

class LYCommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var commentLabel: ActiveLabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加约束
        avatarImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(self.contentView).offset(10.0)
            make.width.height.equalTo(40.0)
        }
        
        usernameButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(5.0)
            make.left.equalTo(self.avatarImageView.snp.right).offset(13.0)
            make.right.lessThanOrEqualTo(self.contentView.snp.centerX)
        }
        
        commentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.usernameButton.snp.bottom).offset(-2.0)
            make.left.equalTo(self.usernameButton)
            make.right.equalTo(self.contentView).offset(-20.0)
            make.bottom.equalTo(self.contentView).offset(-5.0)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(15.0)
            make.right.equalTo(self.contentView).offset(-10)
        }
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
