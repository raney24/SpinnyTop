//
//  UserSettings.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/21/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation

class UserSettings : NSObject {
    static let defaultSettings: UserSettings = UserSettings()
    
    var settingsDictionary: Dictionary<String, Any>
    
    override init() {
        let settingsDictionaryObj: AnyObject? = UserDefaults.standard.value(forKey: "appSettings") as AnyObject
        let dictionary = settingsDictionaryObj as? Dictionary<String, Any>
        self.settingsDictionary = dictionary!
//        } else {
//            self.settingsDictionary = [UserSettings]
//        }
        super.init()
    }
    
//    func setSetting(_ key: String, value: Any) {
//        self.settingsDictionary[key] = value
//        UserDefaults.standard.setValue(self.settingsDictionary, forKey: "appSettings")
//        UserDefaults.standard.synchronize()
//    }
    
    
}
