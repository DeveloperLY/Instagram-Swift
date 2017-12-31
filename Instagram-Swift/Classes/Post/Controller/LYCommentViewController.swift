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
        
        tableView.estimatedRowHeight = width / 5.33
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
                        
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0)  , at: .bottom, animated: false)
                    }
                    self.tableView.reloadData()
                    
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
}

// MARK: - UITextViewDelegate
extension LYCommentViewController: UITextViewDelegate {
    // 当用户输入时调用
    func textViewDidChange(_ textView: UITextView) {
        // 如果没有内容禁用发送按钮
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTextView.text.trimmingCharacters(in: spacing).isEmpty {
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
            if error != nil {
                cell.avatarImageView.image = UIImage(data: data!)
            }
        }
        
        // 评论的时间和当前时间的间隔差
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = Calendar.current.dateComponents(components, from: from, to: now)
        
        if difference.second! <= 0 {
            cell.dateLabel.text = "现在"
        }
        
        if difference.second! > 0 && difference.minute! <= 0 {
            cell.dateLabel.text = "\(difference.second!)秒."
        }
        
        if difference.minute! > 0 && difference.hour! <= 0 {
            cell.dateLabel.text = "\(difference.minute!)分."
        }
        
        if difference.hour! > 0 && difference.day! <= 0 {
            cell.dateLabel.text = "\(difference.hour!)时."
        }
        
        if difference.day! > 0 && difference.weekOfMonth! <= 0 {
            cell.dateLabel.text = "\(difference.day!)天."
        }
        
        if difference.weekOfMonth! > 0 {
            cell.dateLabel.text = "\(difference.weekOfMonth!)周."
        }
        
        return cell
    }
}
