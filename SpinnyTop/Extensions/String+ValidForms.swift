//
//  String+ValidForms.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 1/14/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import Foundation

extension String {
    func isValidPassword(pw: String?) -> Bool {
        guard pw != nil else { return false }
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{4,}")
        return passwordTest.evaluate(with: pw)
    }
}
