//
//  Reading.swift
//  glucose-badge
//
//  Created by Dennis Gove on 1/18/16.
//  Copyright © 2016 gove. All rights reserved.
//

import Foundation

internal struct Reading {
    var value: UInt16
    var timestamp: Date

    internal init(value: UInt16, timestamp: Date){
        self.value = value
        self.timestamp = timestamp
    }
}
