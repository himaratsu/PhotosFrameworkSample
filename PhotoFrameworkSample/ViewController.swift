//
//  ViewController.swift
//  PhotoFrameworkSample
//
//  Created by 平松　亮介 on 2014/11/11.
//  Copyright (c) 2014年 mashroom.in. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var photoAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        reload()
    }

    private func setUpViews() {
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.whiteColor().CGColor
        deleteButton.layer.cornerRadius = 3.0
        deleteButton.layer.masksToBounds = true
    }
    
    private func reload() {
        getAllPhotosInfo()
        
        collectionView.reloadData()
    }

    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        
        let asset = photoAssets[indexPath.row]
        let imageView = cell.viewWithTag(1) as UIImageView

        let manager: PHImageManager = PHImageManager()
        manager.requestImageForAsset(asset,
            targetSize: imageView.frame.size,
            contentMode: .AspectFill,
            options: nil) { (image, info) -> Void in
                imageView.image = image
        }
        
        return cell
    }
    

    // MARK: IBAction
    
    @IBAction func deleteBtnTouched(sender: AnyObject) {
        deleteFirstImage()
    }

    
    // MARK: Photos Framework
    
    private func getAllPhotosInfo() {
        photoAssets = []
        
        var options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        var assets: PHFetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        assets.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            self.photoAssets.append(asset as PHAsset)
        }
        println(photoAssets)
    }
    
    
    private func deleteFirstImage() {
        let delTargetAsset = photoAssets.first as PHAsset?
        
        if delTargetAsset != nil {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                
                // 削除などの変更はこのblocks内でリクエストする
                PHAssetChangeRequest.deleteAssets([delTargetAsset!])
                
                }, completionHandler: { (success, error) -> Void in
                    
                    // 完了時の処理をここに記述
                    if error != nil {
                        println("error occur! \(error)")
                    }
                    else {
                        self.photoAssets.removeAtIndex(0)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.collectionView.reloadData()
                        })
                    }
            })
        }
    }
    
}

