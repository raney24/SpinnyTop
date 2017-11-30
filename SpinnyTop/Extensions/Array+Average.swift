//
//  Array+Average.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/29/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation

extension Array where Element: Numeric {
    // Returns the total sum of elements
    var total: Element {
        return reduce(0, +)
    }
}

extension Array where Element: BinaryInteger {
    // returns the avg of all elements
    var average: Double {
        return isEmpty ? 0 : Double(Int(total)) / Double(count)
    }
}

extension Array where Element: FloatingPoint {
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}
