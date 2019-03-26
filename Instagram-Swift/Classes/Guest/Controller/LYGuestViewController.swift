//
//  LYGuestViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2017/12/29.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

private let reuseIdentifier = "HomePictureCell"

var guestArray = [AVUser]()

class LYGuestViewController: UICollectionViewController {
    
    // 刷新控件
    var refresher: UIRefreshControl!
    
    // 每一页加载帖子的数量
    var onePage: Int = 12
    
    // 从服务器获取数据并存储
    var puuidArray = [String]()
    var pictureArray = [AVFile]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        
        self.navigationItem.title = guestArray.last?.username
        
        // 返回按钮
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        // 移除右边按钮
        self.navigationItem.rightBarButtonItem = nil
        
        // 实现右滑返回
        let backSeipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSeipe.direction = .right
        self.view.addGestureRecognizer(backSeipe)
        
        // 设置刷新控件
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refresher)
        
        // loadPosts
        loadPosts()
    }
    
    // MARK: - Private Methods
    @objc func refresh() -> Void {
        collectionView?.reloadData()
        
        // 停止刷新动画
        refresher.endRefreshing()
    }
    
    @objc func back(_: UIBarButtonItem) -> Void {
        // 退回控制器之前
        self.navigationController?.popViewController(animated: true)
        
        // 从guestArray 中移除最后一个AVUser
        if !guestArray.isEmpty {
            guestArray.removeLast()
        }
    }
    
    // 加载访客发布的帖子
    func loadPosts() -> Void {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: guestArray.last?.username ?? "")
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
                print(error?.localizedDescription ?? "查询访客 Posts 失败")
            }
        }
    }
    
    func loadMore() -> Void {
        if onePage <= pictureArray.count {
            onePage += 12
            
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: guestArray.last?.username ?? "")
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
        followersViewController.user = (guestArray.last?.username)!
        followersViewController.show = "关 注 者"
        self.navigationController?.pushViewController(followersViewController, animated: true)
    }
    
    // 单击关注数后调用的方法
    @objc func followingsTap(_ recognizer: UITapGestureRecognizer) -> Void {
        let followersViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowersController") as! LYFollowersController
        followersViewController.user = (guestArray.last?.username)!
        followersViewController.show = "关 注"
        self.navigationController?.pushViewController(followersViewController, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictureArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeHeaderView", for: indexPath) as! LYHomeHeaderView
        
        // 访客的信息
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last?.username ?? "")
        infoQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                // 判断是否有用户数据
                guard let objects = objects, objects.count > 0 else {
                    let alertController = UIAlertController(title: "\(String(describing: guestArray.last?.username))", message: "用尽力洪荒之力，也没有发现该用户的存在！", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // 用户相关信息
                for object in objects {
                    // 获取信息显示
                    headerView.fullnameLabel.text = (object as AnyObject).object(forKey: "fullname") as? String
                    headerView.bioLabel.text = (object as AnyObject).object(forKey: "bio") as? String
                    headerView.webTextView.text = (object as AnyObject).object(forKey: "web") as? String
                    
                    let avatarQuery = (object as AnyObject).object(forKey: "avatar") as! AVFile
                    avatarQuery.download { (url: URL?, error: Error?) in
                        if url == nil {
                            print(error?.localizedDescription ?? "头像信息获取失败")
                        } else {  headerView.avatarImageView.image = UIImage(contentsOfFile: url!.path)
                        }
                    }
                }
            } else {
                print(error?.localizedDescription ?? "访客信息失败")
            }
        }
        
        // 设置当前用户与访客之间的关注状态
        let followeeQuery = AVUser.current()?.followeeQuery()
        followeeQuery?.whereKey("user", equalTo: AVUser.current() ?? "")
        followeeQuery?.whereKey("followee", equalTo: guestArray.last ?? "")
        followeeQuery?.countObjectsInBackground { (count: Int, error: Error?) in
            guard error == nil else {
                print(error?.localizedDescription ?? "获取当前用户与访客之间的关注状态失败")
                return
            }
            
            // 设置按钮风格
            if count == 0 {
                headerView.followButton.setTitle("关 注", for: .normal)
                headerView.followButton.backgroundColor = .lightGray
            } else {
                headerView.followButton.setTitle("√ 已关注", for: .normal)
                headerView.followButton.backgroundColor = .green
            }
        }
        
        // 计算统计数据
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: guestArray.last?.username ?? "")
        postsQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                headerView.posts.text = String(count)
            } else {
                print(error?.localizedDescription ?? "获取访客帖子数失败")
            }
        }
        
        let followersQuery = AVUser.followerQuery((guestArray.last?.objectId)!)
        followersQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                headerView.followers.text = String(count)
            } else {
                print(error?.localizedDescription ?? "获取访客关注者数失败")
            }
        }
        
        let followeesQuery = AVUser.followeeQuery((guestArray.last?.objectId)!)
        followeesQuery.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                headerView.followings.text = String(count)
            } else {
                print(error?.localizedDescription ?? "获取访客关注数失败")
            }
        }
        
        // 实现统计数的点击手势
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
        
        pictureArray[indexPath.row].download { (url: URL?, error: Error?) in
            if error == nil && (url != nil) {
                cell.pictureImageView.image = UIImage(contentsOfFile: url!.path)
            } else {
                print(error?.localizedDescription ?? "获取图片失败")
            }
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.height {
            self.loadMore()
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LYGuestViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postuuid.append(puuidArray[indexPath.row])
        
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! LYPostViewController
        self.navigationController?.pushViewController(postViewController, animated: true)
    }
}
