//
//  screenSize+Group.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 2/16/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import Foundation
import UIKit

public extension UIScreen {
    var screenSizeGroup: String {
        let width = UIScreen.main.bounds.width
        var screen: String
        if (width > 375) {
            screen = "plus"
        } else if (width < 375) {
            screen = "small"
        } else {
            screen = "normal"
        }
        return screen
    }
    
}
