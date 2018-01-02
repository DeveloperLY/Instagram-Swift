//
//  LYUsersViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2018/1/2.
//  Copyright © 2018年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

class LYUsersViewController: UITableViewController {

    // 搜索栏
    var searchBar = UISearchBar()
    
    // 从云端获取信息后保存数据的数组
    var usernameArray = [String]()
    var avatarArray = [AVFile]()
    
    // 集合视图 UI
    var collectionView: UICollectionView!
    var pictureArray = [AVFile]()
    var puuidArray = [String]()
    var page: Int = 24
    
    // 刷新控件
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 实现Search Bar功能
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.width
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        // load users
        loadUsers()
        
        // 启动集合视图
        collectionViewLaunch()
    }
    
    func loadUsers() {
        let usersQuery = AVUser.query()
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
            if error == nil {
                // 清空数组
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avatarArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.usernameArray.append(((object as AnyObject).username as? String)!)
                    self.avatarArray.append((object as AnyObject).value(forKey: "avatar") as! AVFile)
                }
                
                // 刷新表格视图
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription ?? "加载用户信息失败")
            }
        })
    }
    
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.limit = page
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
            if error == nil {
                // 清空数组
                self.pictureArray.removeAll(keepingCapacity: false)
                self.puuidArray.removeAll(keepingCapacity: false)
                
                // 获取相关数据
                for object in objects! {
                    self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                }
                self.collectionView.reloadData()
            } else {
                print(error?.localizedDescription ?? "加载帖子失败")
            }
        })
    }
    
    func loadMore() {
        // 如果有更多的帖子需要载入
        if page <= pictureArray.count {
            // 增加page的数量
            page += 24
            
            // 载入更多的帖子
            let query = AVQuery(className: "Posts")
            query.limit = page
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    // 清空数组
                    self.pictureArray.removeAll(keepingCapacity: false)
                    self.puuidArray.removeAll(keepingCapacity: false)
                    
                    // 获取相关数据
                    for object in objects! {
                        self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    }
                    self.collectionView.reloadData()
                } else {
                    print(error?.localizedDescription ?? "加载更多帖子失败")
                }
            })
        }
    }
    
    func collectionViewLaunch() {
        // 集合视图的布局
        let layout = UICollectionViewFlowLayout()
        
        // 定义item的尺寸
        layout.itemSize = CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
        
        // 设置滚动方向
        layout.scrollDirection = .vertical
        
        // 定义滚动视图在视图中的位置
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.tabBarController!.tabBar.frame.height - self.navigationController!.navigationBar.frame.height - 20)
        
        // 实例化滚动视图
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        
        // 定义集合视图中的单元格
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PostCell")
        
        // 载入帖子
        loadPosts()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell", for: indexPath) as! LYFollowersCell
        
        // 隐藏 followButton 按钮
        cell.followButton.isHidden = true
        
        cell.usernameLabel.text = usernameArray[indexPath.row]
        avatarArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.avatarImageView.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 获取当前用户选择的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! LYFollowersCell
        
        if cell.usernameLabel.text == AVUser.current()?.username {
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! LYHomeViewController
            self.navigationController?.pushViewController(homeViewController, animated: true)
        } else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameLabel.text ?? "")
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if let object = objects?.last {
                    guestArray.append(object as! AVUser)
                    
                    let guestViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! LYGuestViewController
                    self.navigationController?.pushViewController(guestViewController, animated: true)
                }
            })
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            loadMore()
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension LYUsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let userQuery = AVUser.query()
        userQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        userQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
            if error == nil {
                if objects!.isEmpty {
                    let fullnameQuery = AVUser.query()
                    fullnameQuery.whereKey("fullname", matchesRegex: "(?i)" + searchBar.text!)
                    fullnameQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                        if error == nil {
                            // 清空数组
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avatarArray.removeAll(keepingCapacity: false)
                            
                            // 查找相关数据
                            for object in objects! {
                                self.usernameArray.append(((object as AnyObject).username as? String)!)
                                self.avatarArray.append((object as AnyObject).value(forKey: "avatar") as! AVFile)
                            }
                            
                            self.tableView.reloadData()
                        }
                    })
                } else {
                    // 清空数组
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avatarArray.removeAll(keepingCapacity: false)
                    
                    // 查找相关数据
                    for object in objects! {
                        self.usernameArray.append(((object as AnyObject).username as? String)!)
                        self.avatarArray.append((object as AnyObject).value(forKey: "avatar") as! AVFile)
                    }
                    
                    self.tableView.reloadData()
                }
            }
        })
        
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 当开始搜索的时候，隐藏集合视图
        collectionView.isHidden = true
        
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 当搜索结束后显示集合视图
        collectionView.isHidden = false
        
        searchBar.resignFirstResponder()
        
        searchBar.showsCancelButton = false
        
        searchBar.text = ""
        
        loadUsers()
    }
}

// MARK: - UICollectionView 相关协议
extension LYUsersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath)
        
        let pictureImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        cell.addSubview(pictureImageView)
        
        pictureArray[indexPath.item].getDataInBackground { (data: Data?, error: Error?) in
            if (error == nil) {
                pictureImageView.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription ?? "加载图片失败")
            }
        }
        
        return cell
    }
    
    // Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postuuid.append(puuidArray[indexPath.row])
        
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! LYPostViewController
        self.navigationController?.pushViewController(postViewController, animated: true)
    }
}
