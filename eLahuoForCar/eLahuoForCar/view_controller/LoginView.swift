//
//  LoginView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit


class LoginView: BaseViewController {
    // 底部视图
    @IBOutlet weak var bottomView: UIView!
    // 底部视图的约束
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 监听键盘的弹出与隐藏
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
   
    func keyboardWillShow(note: NSNotification) {

        let keyBoardBounds = (note.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration = (note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

        let deltaY = keyBoardBounds.size.height

        let animations:(() -> Void) = {
            
            self.bottomView.transform = CGAffineTransformMakeTranslation(0,-deltaY)
         }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((note.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
        }else{
            
            animations()
        }
        
    }
    
    func keyboardWillHide(note: NSNotification) {
        
        let duration = (note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {
            
            self.bottomView.transform = CGAffineTransformIdentity
            
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((note.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
        }else{
            
            animations()
        }

    }
    
}
