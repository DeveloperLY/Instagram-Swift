//
//  LYCommentViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/31.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit


var commentuuid = [String]()
var commentowner = [String]()

class LYCommentViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    var refresher = UIRefreshControl()
    
    // 重置UI的默认值
    var tableViewHeight: CGFloat = 0.0
    var commentY: CGFloat = 0.0
    var commentHeight: CGFloat = 0.0
    
    // 存储keyboard大小的变量
    var keyboard = CGRect()
    
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
        
        self.tableView.backgroundColor = .red
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

    func alignment() -> Void {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.height - 20)
        
        tableView.estimatedRowHeight = width / 5.33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentTextView.frame = CGRect(x: 10, y: tableView.frame.height + height / 56.8, width: width / 1.306, height: 33)
        
        commentTextView.layer.cornerRadius = commentTextView.frame.width / 50
        
//        commentTextView.delegate = self
        
        sendButton.frame = CGRect(x: commentTextView.frame.origin.x + commentTextView.frame.width + width / 32, y: commentTextView.frame.origin.y, width: width - (commentTextView.frame.origin.x + commentTextView.frame.width) - width / 32 * 2, height: commentTextView.frame.height)
        
        // assign reseting values
        tableViewHeight = tableView.frame.height
        commentHeight = commentTextView.frame.height
        commentY = commentTextView.frame.origin.y
        
        tableView.estimatedRowHeight = width / 5.33
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
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
