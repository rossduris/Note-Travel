//
//  PhotoCollectionViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 2/4/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import Photos
import CoreData
import BSImagePicker

class PhotoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView:UICollectionView!
    let imagePicker = UIImagePickerController()
    
    var photos = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        imagePicker.delegate = self

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
            }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    override func viewDidLayoutSubviews() {
        let addButton =  UIBarButtonItem(image: UIImage(named: "plus"), style: UIBarButtonItemStyle.Plain,
            target: self, action: "openImagePickerAlbum")
        
        self.parentViewController?.navigationItem.rightBarButtonItem = addButton
        
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
//        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.minimumLineSpacing = 1
//        layout.minimumInteritemSpacing = 0
//        
//        let width = floor(self.collectionView.frame.size.width/3)
//        layout.itemSize = CGSize(width: width, height: width)
//        collectionView.collectionViewLayout = layout

    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCell
        
        let image = photos[indexPath.row]
        
        cell.photoView.image = image
        
        return cell
    }
    
    
    func openImagePickerAlbum(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        photos.append(image)
        collectionView.reloadData()
    }
    

}
