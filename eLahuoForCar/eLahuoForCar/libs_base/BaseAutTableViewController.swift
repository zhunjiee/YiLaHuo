//
//  BaseAutTableViewController.swift
//  eLahuoForCar
//
//  Created by IcenHan on 16/4/1.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire

class BaseAutTableViewController: BaseTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // 照片选择器
    private var mSelectedImageView:UIImageView?
    private var mImageUploadName:String!
    private var mImagePicker:UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 照片选择器
        mImagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            mImagePicker?.sourceType = .Camera
        }
        mImagePicker?.delegate = self
    }
    
    //MARK: - 照片选择器
    func openImageController(imageView:UIImageView, imageName:String) {
        self.mSelectedImageView = imageView
        self.mImageUploadName = imageName
        self.presentViewController(mImagePicker!, animated: true, completion: nil)
    }
    
    // 打开相机
    func openCamera() {
        self.presentViewController(mImagePicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        ToastHub.sharedInstance.showHubWithLoad(self.view, text: "照片处理中...")
        let originalImage:UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            // 图片保存到caches目录
            let cachesPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
            let scaleImagePath = NSString(string: cachesPath!).stringByAppendingPathComponent("\(self.mImageUploadName)")
            let scaleImageData = UIImageJPEGRepresentation(originalImage, 0.3)
            scaleImageData?.writeToFile(scaleImagePath, atomically: true)
            
            // 在这里上传图片
            let imageDic = ["\(self.mImageUploadName!)": scaleImageData!]
            let pramDic = ["title": self.mImageUploadName!]
            ELHUploadFile().uploadFileWithURL(NSURL(string: ApiContants.URL_POST_IMAGE), imageDic: imageDic, pramDic: pramDic, finishBlock: nil)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.mSelectedImageView?.image = originalImage
                ToastHub.sharedInstance.hideHub()
            })
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - 文本选项
    private var mDataResource:Array = [(Int, String)]()
    private var mSelectedValue:String?
    func openTextSelector(showView:UITextField, selectorType:TextSelectorType) {
        var title = ""
        
        // 数据源
        switch selectorType {
        case .VehicleLevel:
            title = "车辆类型"
            mDataResource = MapConstants.sharedInstance.vehicleLevel
        }
        
        let alertController = UIAlertController(title: "\(title)\n\n\n\n\n", message: nil, preferredStyle: .Alert)
        let pickerView = UIPickerView(frame: CGRectMake(0, 0, alertController.view.frame.width - 50, 180))
        pickerView.dataSource = self
        pickerView.delegate = self
        alertController.view.addSubview(pickerView)
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "确认", style: .Default, handler: { (alertAction) in
            showView.text = self.mSelectedValue
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.mDataResource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        let (_, v) = mDataResource[row]
        return v
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let (_, v) = mDataResource[row]
        self.mSelectedValue = v
    }
    
    
    // 保存图片到本地
    func saveImageToLocal(image: UIImage , key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(UIImagePNGRepresentation(image), forKey: key)
    }
    
    // 本地是否有相关图片
    func localHaveImage(key: String) -> Bool {
        let userDefults = NSUserDefaults.standardUserDefaults()
        let imageData = userDefults.objectForKey(key)
        if (imageData != nil) {
            return true
        }
        return false
    }
    
    // 从本地获取图片
    func getImageFromLocal(key: String) -> UIImage {
        let userDefults = NSUserDefaults.standardUserDefaults()
        var localImage: UIImage?
        
        if let imageData = userDefults.objectForKey(key) {
            localImage = UIImage(data: imageData as! NSData)
        } else {
            DevUtils.prints(self, content: "未从本地获得图片")
        }
        
        return localImage!
    }
}
