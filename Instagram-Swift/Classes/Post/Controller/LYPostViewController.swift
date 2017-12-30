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
                self.dateArray.append((object as AnyObject).createdAt as! Date)
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
    
    // MARK: - Event/Touch
    @objc func back(_ sender: UIBarButtonItem) -> Void {
        self.navigationController?.popViewController(animated: true)
        
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
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
