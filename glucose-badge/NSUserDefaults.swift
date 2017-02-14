//
//  NSUserDefaults.swift
//  glucose-badge
//
//  Created by Dennis Gove on 12/5/15.
//  Copyright © 2015 gove. All rights reserved.
//

import Foundation

extension UserDefaults {
    var transmitterId: String {
        get {
            return string(forKey: "transmitterId") ?? "??????"
        }
        set {
            set(newValue, forKey: "transmitterId")
        }
    }
}
