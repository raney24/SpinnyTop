//
//  RoundedButton.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 12/15/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
        clipsToBounds = true
        layer.backgroundColor = BLUE_COLOR.cgColor
        setTitleColor(UIColor.white, for: .normal)
    }
}
