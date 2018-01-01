//
//  LYCommentViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

var commentuuid = [String]()
var commentowner = [String]()

class LYCommentViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    var refresh = UIRefreshControl()
    
    // 重置UI的默认值
    var tableViewHeight: CGFloat = 0.0
    var commentY: CGFloat = 0.0
    var commentHeight: CGFloat = 0.0
    
    // 存储keyboard大小的变量
    var keyboard = CGRect()
    
    var usernameArray = [String]()
    var avatarArray = [AVFile]()
    var commentArray = [String]()
    var dateArray = [Date]()
    
    // page size
    var page: Int = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "评论"
        self.navigationItem.hidesBackButton = true
        
        // 返回按钮
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        // 实现右滑返回
        let backSeipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSeipe.direction = .right
        self.view.addGestureRecognizer(backSeipe)
        
        // 没有内容，发送按钮不可用
        self.sendButton.isEnabled = false
        
        // 如果键盘出现或消失，捕获这两个消息
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        alignment()
        
        loadComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 隐藏底部TabBar
        self.tabBarController?.tabBar.isHidden = true
        
        // 显示键盘
        self.commentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 显示底部TabBar
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Private Methods
    func alignment() -> Void {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.height - 20)
        tableView.dataSource = self
        tableView.delegate = self
        
        commentTextView.frame = CGRect(x: 10, y: tableView.frame.height + height / 56.8, width: width / 1.306, height: 33)
        commentTextView.layer.cornerRadius = commentTextView.frame.width / 50
        commentTextView.delegate = self
        
        sendButton.frame = CGRect(x: commentTextView.frame.origin.x + commentTextView.frame.width + width / 32, y: commentTextView.frame.origin.y, width: width - (commentTextView.frame.origin.x + commentTextView.frame.width) - width / 32 * 2, height: commentTextView.frame.height)
        
        // assign reseting values
        tableViewHeight = tableView.frame.height
        commentHeight = commentTextView.frame.height
        commentY = commentTextView.frame.origin.y
        
        tableView.estimatedRowHeight = LYScreenW / 5.33
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadComments() {
        //  合计出所有的评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground({ (count: Int, error: Error?) in
            if self.page < count {
                self.refresh.addTarget(self, action: #selector(self.loadMore), for: .valueChanged)
                self.tableView.addSubview(self.refresh)
            }
            
            // 获取最新的self.page数量的评论
            let query = AVQuery(className: "Comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    // 清空数组
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.avatarArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                        self.avatarArray.append((object as AnyObject).object(forKey: "avatar") as! AVFile)
                        self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                        self.dateArray.append(((object as AnyObject).createdAt as? Date)!)
                    }
                    self.tableView.reloadData()
                    
                    if self.commentArray.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0)  , at: .bottom, animated: false)
                    }
                } else {
                    print(error?.localizedDescription ?? "加载评论数据失败")
                }
            })
        })
    }
    
    @objc func loadMore() {
        // 合计出所有的评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground({ (count: Int, error: Error?) in
            // 让refresh停止刷新动画
            self.refresh.endRefreshing()
            
            if self.page >= count {
                self.refresh.removeFromSuperview()
            }
            
            // 载入更多的评论
            if self.page < count {
                self.page = self.page + 15
                
                // 从云端查询page个记录
                let query = AVQuery(className: "Comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                    if error == nil {
                        // 清空数组
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.avatarArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                            self.avatarArray.append((object as AnyObject).object(forKey: "avatar") as! AVFile)
                            self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                            self.dateArray.append(((object as AnyObject).createdAt as? Date)!)
                        }
                        self.tableView.reloadData()
                    } else {
                        print(error?.localizedDescription ?? "加载更多评论失败")
                    }
                })
            }
        })
    }
    
    // MARK: - Event/Touch
    // 当键盘出现的时候会调用该方法
    @objc func keyboardWillShow(_ notification: Notification) {
        // 获取到键盘的大小
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]!) as! NSValue
        keyboard = rect.cgRectValue
        
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height
            self.commentTextView.frame.origin.y = self.commentY - self.keyboard.height
            self.sendButton.frame.origin.y = self.commentTextView.frame.origin.y
            
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            self.tableView.frame.size.height = self.tableViewHeight
            
            self.commentTextView.frame.origin.y = self.commentY
            
            self.sendButton.frame.origin.y = self.commentY
            
        })
    }
    
    @objc func back(_: UIBarButtonItem) -> Void {
        // 退回控制器之前
        self.navigationController?.popViewController(animated: true)
        
        // 重置数据
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
    }
    
    @IBAction func sendButtonDidClick(_ sender: UIButton) {
        // 在表格视图中添加一行
        usernameArray.append((AVUser.current()?.username!)!)
        avatarArray.append(AVUser.current()?.object(forKey: "avatar") as! AVFile)
        dateArray.append(Date())
        commentArray.append(commentTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        // 发送评论到云端
        let commentObj = AVObject(className: "Comments")
        commentObj["to"] = commentuuid.last!
        commentObj["username"] = AVUser.current()?.username
        commentObj["avatar"] = AVUser.current()?.object(forKey: "avatar")
        commentObj["comment"] = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        commentObj.saveEventually()
        
        // 发送Hashtag到云端
        let words: [String] = commentTextView.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            // 定义正则表达式
            let pattern = "#[^#]+";
            let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
            let results = regular.matches(in: word, options: .reportProgress , range: NSMakeRange(0, word.count))
            
            //输出截取结果
            print("符合的结果有\(results.count)个")
            for result in results {
                word = (word as NSString).substring(with: result.range)
            }
            
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = AVObject(className: "Hashtags")
                hashtagObj["to"] = commentuuid.last
                hashtagObj["by"] = AVUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = commentTextView.text
                hashtagObj.saveInBackground({ (success: Bool, error: Error?) in
                    if success {
                        print("hashtag \(word) 已经被创建。")
                    } else {
                        print(error?.localizedDescription ?? "提交Hashtag失败")
                    }
                })
            }
        }
        
        // scroll to bottom
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section: 0), at: .bottom, animated: false)
        
        // 重置UI
        commentTextView.text = ""
        commentTextView.frame.size.height = commentHeight
        commentTextView.frame.origin.y = sender.frame.origin.y
        tableView.frame.size.height = tableViewHeight - keyboard.height - commentTextView.frame.height + commentHeight
    }
    
    @IBAction func usernameButtonDidClick(_ sender: UIButton) {
        // 按钮 index
        let indexPath = sender.layer.value(forKey: "index") as! IndexPath
        
        // 获取点击Cell
        let cell = tableView.cellForRow(at: indexPath) as! LYCommentCell
        
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
    
    
}

// MARK: - UITextViewDelegate
extension LYCommentViewController: UITextViewDelegate {
    // 当用户输入时调用
    func textViewDidChange(_ textView: UITextView) {
        // 如果没有内容禁用发送按钮
        if !commentTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        
        if textView.contentSize.height > textView.frame.height && textView.frame.height < 130.0 {
            
            let difference = textView.contentSize.height - textView.frame.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            // 上移tableView
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        } else if textView.contentSize.height < textView.frame.height {
            let difference = textView.frame.height - textView.contentSize.height
            
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            // 上移tableView
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LYCommentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! LYCommentCell
        
        cell.usernameButton.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.usernameButton.sizeToFit()
        cell.commentLabel.text = commentArray[indexPath.row]
        avatarArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.avatarImageView.image = UIImage(data: data!)
            }
        }
        
        // 评论的时间和当前时间的间隔差
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
        
        // @mentions is tapped
        cell.commentLabel.userHandleLinkTapHandler = { label, handle, rang in
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
        cell.commentLabel.hashtagLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.dropFirst())
            hashtags.append(mention)
            
            let hashtagsViewController = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsViewController") as! LYHashtagsViewController
            self.navigationController?.pushViewController(hashtagsViewController, animated: true)
            
        }
        
        cell.usernameButton.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    // 设置Cell可编辑
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 划动单元格的Action
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // 获取用户所划动的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! LYCommentCell
        
        // Delete
        let delete = UITableViewRowAction(style: .normal, title: " "){(UITableViewRowAction, IndexPath) -> Void in
            // 从云端删除评论
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentLabel.text!)
            commentQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    // 找到相关记录
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                } else {
                    print(error?.localizedDescription ?? "删除评论失败")
                }
            })
            
            // 从云端删除 Hashtag
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("to", equalTo: commentuuid.last ?? "")
            hashtagQuery.whereKey("by", equalTo: cell.usernameButton.titleLabel?.text ?? "")
            hashtagQuery.whereKey("comment", equalTo: cell.commentLabel.text ?? "")
            hashtagQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            })
            
            // 从表格视图删除单元格
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.avatarArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            // 关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        // Address
        let address = UITableViewRowAction(style: .normal, title: " ") {(action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            // 在Text View中包含Address
            self.commentTextView.text = "\(self.commentTextView.text + "@" + self.usernameArray[indexPath.row] + " ")"
            // 让发送按钮生效
            self.sendButton.isEnabled = true
            // 关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        // 投诉评论
        let complain = UITableViewRowAction(style: .normal, title: " "){(action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            // 发送投诉到云端
            let complainObj = AVObject(className: "Complain")
            complainObj["by"] = AVUser.current()?.username
            complainObj["post"] = commentuuid.last
            complainObj["to"] = cell.commentLabel.text
            complainObj["owner"] = cell.usernameButton.titleLabel?.text
            
            complainObj.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    self.alert(error: "投诉信息已经被成功提交！", message: "感谢您的支持，我们将关注您提交的投诉！")
                } else{
                    self.alert(error: "错误", message: error!.localizedDescription)
                }
            })
            
            // 关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        // 按钮的背景颜色
//        delete.backgroundColor = .red
//        address.backgroundColor = .gray
//        complain.backgroundColor = .gray
        
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete.png")!)
        address.backgroundColor = UIColor(patternImage: UIImage(named: "address.png")!)
        complain.backgroundColor = UIColor(patternImage: UIImage(named: "complain.png")!)
        
        if cell.usernameButton.titleLabel?.text == AVUser.current()?.username {
            return [delete, address]
        } else if commentowner.last == AVUser.current()?.username {
            return [delete, address, complain]
        } else {
            return [address, complain]
        }
    }
    
    // 消息警告
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
}
