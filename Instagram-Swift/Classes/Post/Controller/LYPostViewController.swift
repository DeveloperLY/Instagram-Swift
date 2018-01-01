//
//  LYPostViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

var postuuid = [String]()


class LYPostViewController: UITableViewController {
    
    // 从服务器获取数据后写入到相应的数组中
    var avatarArray = [AVFile]()
    var usernameArray = [String]()
    var dateArray = [Date]()
    var pictureArray = [AVFile]()
    var puuidArray = [String]()
    var titleArray = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNav()
        
        // 实现右滑返回
        let backSeipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSeipe.direction = .right
        self.view.addGestureRecognizer(backSeipe)
        
        // 动态Cell高度设置
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 550.0
        
        loadData()
        
        // 监听通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: NSNotification.Name(rawValue: "liked"), object: nil)
    }
    
    func loadData() -> Void {
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("puuid", equalTo: postuuid.last ?? "")
        postQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            // 清空数组
            self.avatarArray.removeAll(keepingCapacity: false)
            self.usernameArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.pictureArray.removeAll(keepingCapacity: false)
            self.puuidArray.removeAll(keepingCapacity: false)
            self.titleArray.removeAll(keepingCapacity: false)
            
            for object in objects! {
                self.avatarArray.append((object as AnyObject).value(forKey: "avatar") as! AVFile)
                self.usernameArray.append((object as AnyObject).value(forKey: "username") as! String)
                self.dateArray.append(((object as AnyObject).createdAt as? Date)!)
                self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                self.titleArray.append((object as AnyObject).value(forKey: "title") as! String)
            }
            
            self.tableView.reloadData()
        }
        
    }

    func setUpNav() -> Void {
        // 返回按钮
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    // 消息警告
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Event/Touch
    @objc func back(_ sender: UIBarButtonItem) -> Void {
        self.navigationController?.popViewController(animated: true)
        
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
    }
    
    @objc func refresh(_ notification: Notification) -> Void {
        tableView.reloadData()
    }
    
    @IBAction func usernameButtonDidClick(_ sender: UIButton) {
        // 按钮 index
        let indexPath = sender.layer.value(forKey: "index") as! IndexPath
        
        // 获取点击Cell
        let cell = tableView.cellForRow(at: indexPath) as! LYPostCell
        if cell.usernameButton.titleLabel?.text == AVUser.current()?.username {
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! LYHomeViewController
            self.navigationController?.pushViewController(homeViewController, animated: true)
        } else {
            let guestViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! LYGuestViewController
            self.navigationController?.pushViewController(guestViewController, animated: true)
        }
        
    }
    
    @IBAction func commentButtonDidClick(_ sender: UIButton) {
        let indexPath = sender.layer.value(forKey: "index") as! IndexPath
        
        // 获取点击Cell
        let cell = tableView.cellForRow(at: indexPath) as! LYPostCell
        
        // 存储相关数据到全局变量
        commentuuid.append(cell.puuidLabel.text!)
        commentowner.append((cell.usernameButton.titleLabel?.text)!)
        
        // 进入评论页面
        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! LYCommentViewController
        self.navigationController?.pushViewController(commentViewController, animated: true)
        
    }
    
    @IBAction func moreButtonDidClick(_ sender: UIButton) {
        let indexPath = sender.layer.value(forKey: "index") as! IndexPath
        // 获取点击Cell
        let cell = tableView.cellForRow(at: indexPath) as! LYPostCell
        
        // 删除操作
        let deleteAction = UIAlertAction(title: "删除", style: .default) { (alertAction: UIAlertAction) in
            // 删除本地
            self.usernameArray.remove(at: indexPath.row)
            self.avatarArray.remove(at: indexPath.row)
            self.pictureArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.titleArray.remove(at: indexPath.row)
            self.puuidArray.remove(at: indexPath.row)
            
            // 删除云端数据
            let postQuery = AVQuery(className: "Posts")
            postQuery.whereKey("puuid", equalTo: cell.puuidLabel.text ?? "")
            postQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteInBackground({ (success: Bool, error: Error?) in
                            if success {
                                // 发送通知到 rootViewController 更新帖子
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                                // 销毁当前控制器
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                print(error?.localizedDescription ?? "删除帖子失败")
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription ?? "查询要删除的帖子失败")
                }
            })
            
            // 删除帖子的 Like 记录
            let likeQuery = AVQuery(className: "Likes")
            likeQuery.whereKey("to", equalTo: cell.puuidLabel.text ?? "")
            likeQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            })
            
            // 删除帖子相关评论
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: cell.puuidLabel.text ?? "")
            commentQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            })
            
            // 删除帖子相关的 Hashtag
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.puuidLabel.text ?? "")
            hashtagQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            })
        }
        
        let complainAction = UIAlertAction(title: "投诉", style: .default) { (alertAction: UIAlertAction) in
            // 发送投诉到云端
            let complainObject = AVObject(className: "Complain")
            complainObject["by"] = AVUser.current()?.username
            complainObject["post"] = cell.puuidLabel.text
            complainObject["to"] = cell.titleLabel.text
            complainObject["owner"] = cell.usernameButton.titleLabel?.text
            
            complainObject.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    self.alert(error: "投诉信息已经被成功提交！", message: "感谢您的支持，我们将关注您提交的投诉！")
                } else{
                    self.alert(error: "错误", message: error!.localizedDescription)
                }
            })
        }
        
        // 取消操作
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        // 创建 AlertController
        let alertController = UIAlertController(title: "更多操作", message: nil, preferredStyle: .actionSheet)
        
        if cell.usernameButton.titleLabel?.text == AVUser.current()?.username {
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
        } else {
            alertController.addAction(complainAction)
            alertController.addAction(cancelAction)
        }
        
        // show
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 从表格视图的可复用队列中获取单元格对象
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! LYPostCell
        
        // 通过数组信息关联单元格中的UI控件
        cell.usernameButton.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.usernameButton.sizeToFit()
        
        cell.puuidLabel.text = puuidArray[indexPath.row]
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.titleLabel.sizeToFit()
        
        // 配置用户头像
        avatarArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            cell.avatarImageView.image = UIImage(data: data!)
        }
        
        // 配置帖子照片
        pictureArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            cell.pictureImageView.image = UIImage(data: data!)
        }
        
        // 帖子的发布时间和当前时间的间隔差
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
        
        // 处理用户喜欢按钮
        let didLike = AVQuery(className: "Likes")
        didLike.whereKey("by", equalTo: AVUser.current()?.objectId ?? "")
        didLike.whereKey("to", equalTo: cell.puuidLabel.text ?? "")
        didLike.countObjectsInBackground { (count: Int, error: Error?) in
            if count == 0 {
                cell.likeButton.isSelected = false
            } else {
                cell.likeButton.isSelected = true
            }
        }
        
        // 计算帖子喜爱总数
        let countLikes = AVQuery(className: "Likes")
        countLikes.whereKey("to", equalTo: cell.puuidLabel.text ?? "")
        countLikes.countObjectsInBackground { (count: Int, error: Error?) in
            cell.likeLabel.text = String(count)
        }
        
        // 将indexPath赋值给usernameButton 的 layer属性
        cell.usernameButton.layer.setValue(indexPath, forKey: "index")
        
        // 将indexPath赋值给commentButton 的 layer属性
        cell.commentButton.layer.setValue(indexPath, forKey: "index")
        
        // 将indexPath赋值给 moreButton 的 layer 属性
        cell.moreButton.layer.setValue(indexPath, forKey: "index")
        
        // @mentions is tapped
        cell.titleLabel.userHandleLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.dropFirst())
            
            if mention == AVUser.current()?.username {
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! LYHomeViewController
                self.navigationController?.pushViewController(homeViewController, animated: true)
            } else {
                let query = AVUser.query()
                query.whereKey("username", equalTo: mention)
                query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                    if let object = objects?.last {
                        guestArray.append(object as! AVUser)
                        
                        let guestViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! LYGuestViewController
                        self.navigationController?.pushViewController(guestViewController, animated: true)
                    }
                })
            }
        }
        
        // #hashtag is tapped
        cell.titleLabel.hashtagLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.dropFirst())
            hashtags.append(mention)
            
            let hashtagsViewController = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsViewController") as! LYHashtagsViewController
            self.navigationController?.pushViewController(hashtagsViewController, animated: true)
            
        }
        
        return cell
    }

}
