//
//  UIImageViewRounded.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 12/14/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class UIImageViewRounded: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
