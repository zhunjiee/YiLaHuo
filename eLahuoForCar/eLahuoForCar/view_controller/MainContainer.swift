//
//  MainContainer.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/23.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class MainContainer: SlideMenuController {
    
    override func awakeFromNib() {
        SlideMenuOptions.leftViewWidth = 220
        SlideMenuOptions.contentViewScale = 1
        
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier(IdentityConstants.MainViewNar) {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier(IdentityConstants.SlideMenuView) {
            self.leftViewController = controller
        }
        super.awakeFromNib()
    }
    
}
