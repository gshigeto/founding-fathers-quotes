//
//  RotatingNavigationController.swift
//  Founding Fathers Quote Book
//
//  Created by Gavin Nitta on 9/23/17.
//  Copyright © 2017 Steve Liddle. All rights reserved.
//

import UIKit

class RotatingNavigationController : UINavigationController {
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
