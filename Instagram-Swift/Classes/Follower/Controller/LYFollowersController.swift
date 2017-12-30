//
//  LYFollowersController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/29.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYFollowersController: UITableViewController {
    
    var show = String()
    var user = String()
    
    var followerArray = [AVUser]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = show
        
        if show == "关 注 者" {
            loadFollowers()
        } else {
            loadFollowings()
        }
    }

    // MARK: - loadData
    func loadFollowers() -> Void {
        AVUser.current()?.getFollowers({ (followers: [Any]?, error: Error?) in
            if error == nil && followers != nil {
                self.followerArray = followers! as! [AVUser]
                
                // 刷新
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription ?? "loadFollowers 失败...")
            }
        })
    }
    
    func loadFollowings() -> Void {
        AVUser.current()?.getFollowees({ (followings: [Any]?, error: Error?) in
            if error == nil && followings != nil {
                self.followerArray = followings! as! [AVUser]
                
                // 刷新
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription ?? "loadFollowers 失败...")
            }
        })
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followerArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell", for: indexPath) as! LYFollowersCell
        
        cell.usernameLabel.text = followerArray[indexPath.row].username
        let avatar = followerArray[indexPath.row].object(forKey: "avatar") as! AVFile
        avatar.getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.avatarImageView.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription ?? "获取图片失败")
            }
        }
        
        // 处理关注和未关注的按钮状态
        let query = followerArray[indexPath.row].followeeQuery()
        query.whereKey("user", equalTo: AVUser.current() ?? "")
        query.whereKey("followee", equalTo: followerArray[indexPath.row])
        query.countObjectsInBackground { (count: Int, error: Error?) in
            // 设置按钮风格
            if error == nil {
                if count == 0 {
                    cell.followButton.setTitle("关 注", for: .normal)
                    cell.followButton.backgroundColor = .lightGray
                } else {
                    cell.followButton.setTitle("√ 已关注", for: .normal)
                    cell.followButton.backgroundColor = .green
                }
            }
        }
        
        // 将关注人对象传递给Cell
        cell.user = followerArray[indexPath.row]
        
        // 当前用户隐藏关注按钮
        if cell.usernameLabel.text == AVUser.current()?.username {
            cell.followButton.isHidden = true
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width / 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 获取用户点击单元格的用户对象
        let cell = tableView.cellForRow(at: indexPath) as! LYFollowersCell
        
        if cell.usernameLabel.text == AVUser.current()?.username {
            let homeViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! LYHomeViewController
            self.navigationController?.pushViewController(homeViewController, animated: true)
        } else {
            guestArray.append(followerArray[indexPath.row])
            let guestViewController = storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! LYGuestViewController
            self.navigationController?.pushViewController(guestViewController, animated: true)
        }
    }

}
