//
//  StaticValuesReceiver.swift
//  glucose-badge
//
//  Created by Dennis Gove on 1/18/16.
//  Copyright © 2016 gove. All rights reserved.
//

import Foundation

// Implements a receiver which will iterate through a list of static
// values at some fixed rate. This can be used for testing purposes.

class StaticValuesReceiver : NSObject, Receiver {

    fileprivate var notifier: ReceiverNotificationDelegate?
    fileprivate var readings: [Reading]?
    fileprivate var valueChangeInterval: Double
    fileprivate var valueSender: Timer?
    fileprivate var nextValueIdx: Int
    fileprivate var latestReading: Reading?

    internal init(readings: [Reading]?, valueChangeInterval: Double) {
        self.readings = readings
        self.valueChangeInterval = valueChangeInterval
        self.nextValueIdx = 0
    }


    func sendNextValue() {
        if(nil != notifier && nil != readings){
            var reading = readings![nextValueIdx]
            reading.timestamp = Date()
            latestReading = reading
            sendReceiverEvent(ReceiverEventCode.connected_LAST_READING_GOOD, withLatestReading: latestReading)
            nextValueIdx = (nextValueIdx + 1) % readings!.count
        }
    }

    // Begin sending values through the notifier
    // Returns false if no values exist to send or notifier is null
    func connect() -> Bool {
        if(nil == self.notifier || nil == self.readings || 0 == self.readings?.count){
            sendReceiverEvent(ReceiverEventCode.disconnected, withLatestReading: latestReading)
            return false
        }

        if(nil == valueSender){
            valueSender = Timer.scheduledTimer(timeInterval: valueChangeInterval, target: self, selector: #selector(StaticValuesReceiver.sendNextValue), userInfo: nil, repeats: true)
            sendReceiverEvent(ReceiverEventCode.connected_WAITING_FOR_FIRST_READING, withLatestReading: latestReading)
        }
        return true
    }

    // Stop sending values through the notifier
    // Always returns true
    func disconnect() -> Bool {
        if(nil != valueSender){
            valueSender?.invalidate()
            valueSender = nil
            sendReceiverEvent(ReceiverEventCode.disconnected, withLatestReading: latestReading)
        }
        return true
    }

    func sendReceiverEvent(_ eventCode: ReceiverEventCode, withLatestReading: Reading?){
        if(nil != notifier){
            notifier!.receiver(self, hadEvent: eventCode, withLatestReading: withLatestReading)
        }
    }

    var readingNotifier: ReceiverNotificationDelegate? {
        get{ return self.notifier }
        set{ self.notifier = newValue }
    }

}
