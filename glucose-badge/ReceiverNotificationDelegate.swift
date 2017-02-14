//
//  ReceiverNotificationDelegate.swift
//  glucose-badge
//
//  Created by Dennis Gove on 1/18/16.
//  Copyright © 2016 gove. All rights reserved.
//

import Foundation

protocol ReceiverNotificationDelegate: class {
    func receiver(_ receiver: Receiver, hadEvent: ReceiverEventCode, withLatestReading: Reading?)
}
