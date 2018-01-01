//
//  LYHashtagsViewController.swift
//  Instagram-Swift
//
//  Created by LiuY on 2018/1/2.
//  Copyright © 2018年 DeveloperLY. All rights reserved.
//

import UIKit
import AVOSCloud

private let reuseIdentifier = "HashtagsCell"

var hashtags = [String]()

class LYHashtagsViewController: UICollectionViewController {
    
    // UI Objects
    var refresher: UIRefreshControl!
    var page: Int = 24
    
    // 从云端获取记录后，存储数据的数组
    var pictureArray = [AVFile]()
    var puuidArray = [String]()
    var filterArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.alwaysBounceVertical = true
        self.navigationItem.title = "#" + "\(hashtags.last!.uppercased())"
        
        // 返回按钮
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        // 实现右滑返回
        let backSeipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSeipe.direction = .right
        self.view.addGestureRecognizer(backSeipe)
        
        // 设置刷新控件
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refresher)
        
        // 加载数据
        loadHashtags()
    }

    // MARK: - Private Methods
    @objc func refresh() -> Void {
        loadHashtags()
    }
    
    @objc func back(_: UIBarButtonItem) -> Void {
        // 退回控制器之前
        self.navigationController?.popViewController(animated: true)
        
        // 从hashtags 中移除最后一个主题标签
        if !hashtags.isEmpty {
            hashtags.removeLast()
        }
    }
    
    // 加载Hashtag
    func loadHashtags() -> Void {
        // 获取与Hashtag相关的帖子
        let hashtagQuery = AVQuery(className: "Hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtags.last!)
        hashtagQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
            if error == nil {
                // 清空 filterArray 数组
                self.filterArray.removeAll(keepingCapacity: false)
                
                // 存储相关的帖子到filterArray数组
                for object in objects! {
                    self.filterArray.append((object as AnyObject).value(forKey: "to") as! String)
                }
                
                // 通过filterArray的uuid，找出相关的帖子
                let query = AVQuery(className: "Posts")
                query.whereKey("puuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                    if error == nil {
                        // 清空数组
                        self.pictureArray.removeAll(keepingCapacity: false)
                        self.puuidArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                            self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        }
                        
                        // reload
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                    } else {
                        print(error?.localizedDescription ?? "根据filter获取帖子失败")
                    }
                })
            } else {
                print(error?.localizedDescription ?? "获取与Hashtag相关的帖子失败")
            }
        })
    }
    
    func loadMore() -> Void {
        // 如果服务器端的帖子大于默认显示数量
        if page <= puuidArray.count {
            page = page + 15
            
            // 获取与Hashtag相关的帖子
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtags.last!)
            hashtagQuery.findObjectsInBackground({ (objects :[Any]?, error: Error?) in
                if error == nil {
                    // 清空 filterArray 数组
                    self.filterArray.removeAll(keepingCapacity: false)
                    
                    // 存储相关的帖子到filterArray数组
                    for object in objects! {
                        self.filterArray.append((object as AnyObject).value(forKey: "to") as! String)
                    }
                    
                    // 通过filterArray的uuid，找出相关的帖子
                    let query = AVQuery(className: "Posts")
                    query.whereKey("puuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                        if error == nil {
                            // 清空数组
                            self.pictureArray.removeAll(keepingCapacity: false)
                            self.puuidArray.removeAll(keepingCapacity: false)
                            
                            for object in objects! {
                                self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                            }
                            
                            // reload
                            self.collectionView?.reloadData()
                        } else {
                            print(error?.localizedDescription ?? "根据filter获取帖子失败")
                        }
                    })
                } else {
                    print(error?.localizedDescription ?? "获取与Hashtag相关的帖子失败")
                }
            })
        }
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictureArray.count
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
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3 {
            loadMore()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LYHashtagsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postuuid.append(puuidArray[indexPath.row])
        
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! LYPostViewController
        self.navigationController?.pushViewController(postViewController, animated: true)
    }
}
