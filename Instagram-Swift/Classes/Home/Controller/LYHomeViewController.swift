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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        title = AVUser.current()?.username
        
        
        // 设置刷新控件
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refresher)
        
        // 加载数据
        loadPosts()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
            headerView.avatarImageView.image = UIImage(data: data!)
        }
    
        return headerView
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LYHomePictureCell
    
        // Configure the cell
        // 从pictureArray 中获取图片
        pictureArray[indexPath.item].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.pictureImageView.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription ?? "获取图片失败")
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
