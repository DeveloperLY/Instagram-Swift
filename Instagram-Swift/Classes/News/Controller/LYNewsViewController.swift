//
//  LYNewsViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2018/1/2.
//  Copyright © 2018年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYNewsViewController: UITableViewController {
    
    // 存储云端数据到数组
    var usernameArray = [String]()
    var avatarArray = [AVFile]()
    var typeArray = [String]()
    var dateArray = [Date]()
    var puuidArray = [String]()
    var ownerArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 动态调整表格的高度
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        // 导航栏的title
        self.navigationItem.title = "通知"
        
        // 加载通知
        loadNews()
    }
    
    func loadNews() -> Void {
        // 从云端载入通知数据
        let query = AVQuery(className: "News")
        query.whereKey("to", equalTo: AVUser.current()?.username ?? "")
        query.limit = 30
        query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
            if error == nil {
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avatarArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.puuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.usernameArray.append((object as AnyObject).value(forKey: "by") as! String)
                    self.avatarArray.append((object as AnyObject).value(forKey: "avatar") as! AVFile)
                    self.typeArray.append((object as AnyObject).value(forKey: "type") as! String)
                    self.dateArray.append(((object as AnyObject).createdAt as? Date)!)
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.ownerArray.append((object as AnyObject).value(forKey: "owner") as! String)
                    
                    (object as! AVObject).setObject("yes", forKey: "checked")
                    (object as! AVObject).saveEventually()
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - Event/Touch
    @IBAction func usernameButtonDidClick(_ sender: UIButton) {
        // 按钮 index
        let indexPath = sender.layer.value(forKey: "index") as! IndexPath
        
        // 获取点击Cell
        let cell = tableView.cellForRow(at: indexPath) as! LYNewsCell
        
        if cell.usernameButton.titleLabel?.text == AVUser.current()?.username {
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! LYHomeViewController
            self.navigationController?.pushViewController(homeViewController, animated: true)
        } else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameButton.titleLabel?.text ?? "")
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if let object = objects?.last {
                    guestArray.append(object as! AVUser)
                    
                    let guestViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! LYGuestViewController
                    self.navigationController?.pushViewController(guestViewController, animated: true)
                }
            })
        }
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! LYNewsCell
        
        cell.usernameButton.setTitle(usernameArray[indexPath.row], for: .normal)
        avatarArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.avatarImageView.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription ?? "加载通知用户头像失败")
            }
        }
        
        // 消息的发布时间和当前时间的间隔差
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = Calendar.current.dateComponents(components, from: from, to: now)
        
        if difference.second! <= 0 {
            cell.dateLabel.text = "刚刚"
        }
        
        if difference.second! > 0 && difference.minute! <= 0 {
            cell.dateLabel.text = "\(difference.second!)秒前"
        }
        
        if difference.minute! > 0 && difference.hour! <= 0 {
            cell.dateLabel.text = "\(difference.minute!)分前"
        }
        
        if difference.hour! > 0 && difference.day! <= 0 {
            cell.dateLabel.text = "\(difference.hour!)时前"
        }
        
        if difference.day! > 0 && difference.weekOfMonth! <= 0 {
            cell.dateLabel.text = "\(difference.day!)天前"
        }
        
        if difference.weekOfMonth! > 0 {
            cell.dateLabel.text = "\(difference.weekOfMonth!)周前"
        }
        
        // 定义info文本信息
        if typeArray[indexPath.row] == "mention" {
            cell.infoLabel.text = "@mention了你"
        }
        if typeArray[indexPath.row] == "comment" {
            cell.infoLabel.text = "评论了你的帖子"
        }
        if typeArray[indexPath.row] == "follow" {
            cell.infoLabel.text = "关注了你"
        }
        if typeArray[indexPath.row] == "like" {
            cell.infoLabel.text = "喜欢你的帖子"
        }
        
        // 赋值indexPath给usernameButton
        cell.usernameButton.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LYNewsCell
        
        // 跳转到comment或@mention
        if cell.infoLabel.text == "评论了你的帖子" || cell.infoLabel.text == "@mention了你" {
            commentuuid.append(puuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            
            // 跳转到评论页面
            let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! LYCommentViewController
            self.navigationController?.pushViewController(commentViewController, animated: true)
        }
        
        // 跳转到关注人的页面
        if cell.infoLabel.text == "关注了你" {
            // 获取关注人的AVUser对象
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameButton.titleLabel?.text ?? "")
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if let object = objects?.last {
                    guestArray.append(object as! AVUser)
                    
                    // 跳转到访客页面
                    let guestViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! LYGuestViewController
                    self.navigationController?.pushViewController(guestViewController, animated: true)
                }
            })
        }
        
        // 跳转到帖子页面
        if cell.infoLabel.text == "喜欢你的帖子" {
            postuuid.append(puuidArray[indexPath.row])
            
            let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! LYPostViewController
            self.navigationController?.pushViewController(postViewController, animated: true)
        }
    }

}
