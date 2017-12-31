//
//  LYHomeViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/29.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

private let reuseIdentifier = "HomePictureCell"

class LYHomeViewController: UICollectionViewController {
    
    // 刷新控件
    var refresher: UIRefreshControl!
    
    // 每一页加载帖子的数量
    var onePage: Int = 12
    
    var puuidArray = [String]()
    var pictureArray = [AVFile]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置集合视图在垂直方向上反弹的效果
        self.collectionView?.alwaysBounceVertical = true
        
        self.navigationItem.title = AVUser.current()?.username
        
        // 设置刷新控件
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refresher)
        
        // 加载数据
        loadPosts()
        
        // 监听数据刷新
        NotificationCenter.default.addObserver(self, selector: #selector(reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    @objc func refresh() -> Void {
        collectionView?.reloadData()
        
        // 停止刷新动画
        refresher.endRefreshing()
    }

    func loadPosts() -> Void {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: AVUser.current()?.username ?? "")
        query.limit = onePage
        query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            // 加载成功
            if error == nil {
                // 清空两个数组
                self.puuidArray.removeAll(keepingCapacity: false)
                self.pictureArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    // 将查询到的数据添加到数组中去
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                }
                
                self.collectionView?.reloadData()
            } else {
                print(error?.localizedDescription ?? "查询 Posts 失败")
            }
        }
    }
    
    func loadMore() -> Void {
        if onePage <= pictureArray.count {
            onePage += 12
            
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: AVUser.current()?.username ?? "")
            query.limit = onePage
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                // 查询成功
                if error == nil {
                    // 清空两个数组
                    self.puuidArray.removeAll(keepingCapacity: false)
                    self.pictureArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        // 将查询到的数据添加到数组中
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                    }
                    print("loaded + \(self.onePage)")
                    self.collectionView?.reloadData()
                } else {
                    print(error?.localizedDescription ?? "加载更多帖子失败")
                }
            })
        }
    }
    
    // MARK: - Event
    // 单击帖子数后调用的方法
    @objc func postsTap(_ recognizer: UITapGestureRecognizer) -> Void {
        if !pictureArray.isEmpty {
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    // 单击关注者数后调用的方法
    @objc func followersTap(_ recognizer: UITapGestureRecognizer) -> Void {
        let followersViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowersController") as! LYFollowersController
        followersViewController.user = (AVUser.current()?.username)!
        followersViewController.show = "关 注 者"
        self.navigationController?.pushViewController(followersViewController, animated: true)
    }
    
    // 单击关注数后调用的方法
    @objc func followingsTap(_ recognizer: UITapGestureRecognizer) -> Void {
        let followersViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowersController") as! LYFollowersController
        followersViewController.user = (AVUser.current()?.username)!
        followersViewController.show = "关 注"
        self.navigationController?.pushViewController(followersViewController, animated: true)
    }
    
    @objc func reload(_ notification: Notification) -> Void {
        collectionView?.reloadData()
    }
    
    @objc func uploaded(_ notification: Notification) -> Void {
        loadPosts()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        // 退出用户登录
        AVUser.logOut()
        
        // 移除本地登录信息
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.synchronize()
        
        // 进入登录控制器
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LYLoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginViewController
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictureArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HomeHeaderView", for: indexPath) as! LYHomeHeaderView
        
        // 获取信息显示
        headerView.fullnameLabel.text = AVUser.current()?.object(forKey: "fullname") as? String
        headerView.webTextView.text = AVUser.current()?.object(forKey: "web") as? String
        headerView.bioLabel.text = AVUser.current()?.object(forKey: "bio") as? String
        
        let avatarQuery = AVUser.current()?.object(forKey: "avatar") as! AVFile
        avatarQuery.getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                headerView.avatarImageView.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription ?? "头像信息获取失败")
            }
        }
        
        let currentUser: AVUser = AVUser.current()!
        
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: currentUser.username ?? "")
        postsQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                headerView.posts.text = String(count)
            }
        }
        
        let followersQuery = AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: currentUser)
        followersQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                headerView.followers.text = String(count)
            }
        }
        
        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: currentUser)
        followeesQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                headerView.followings.text = String(count)
            }
        }
        
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        headerView.posts.addGestureRecognizer(postsTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        headerView.followers.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        headerView.followings.addGestureRecognizer(followingsTap)
        
        return headerView
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LYHomePictureCell
    
        // Configure the cell
        // 从pictureArray 中获取图片
        pictureArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.pictureImageView.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription ?? "获取图片失败")
            }
        }
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.height {
            self.loadMore()
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LYHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postuuid.append(puuidArray[indexPath.row])
        
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! LYPostViewController
        self.navigationController?.pushViewController(postViewController, animated: true)
    }
}
