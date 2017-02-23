//
//  xDripG5Receiver.swift
//  glucose-badge
//
//  Created by Dennis Gove on 1/21/16.
//  Copyright © 2016 gove. All rights reserved.
//

import Foundation
import CoreBluetooth
import xDripG5

class xDripG5Receiver: NSObject, Receiver, TransmitterDelegate {

    fileprivate var transmitter: Transmitter!
    fileprivate var notifier: ReceiverNotificationDelegate?
    fileprivate var latestReading: Reading?
    fileprivate var disconnectTimer: Timer?
    fileprivate final var xDripG5Timeout = (Double)(60 * 6) // we will allow 6 minutes before calling a disconnect

    internal init(transmitterId: String) {
        super.init()
        
        transmitter = Transmitter(
            ID: transmitterId,
            passiveModeEnabled: true
        )
        transmitter?.stayConnected = true
        transmitter?.delegate = self

    }

    var readingNotifier: ReceiverNotificationDelegate? {
        get{ return self.notifier }
        set{ self.notifier = newValue }
    }

    func connect() -> Bool {
        transmitter.resumeScanning()
        self.resetDisconnectTimer()
        sendReceiverEvent(ReceiverEventCode.connected_WAITING_FOR_FIRST_READING, withLatestReading: latestReading)
        return true
    }

    func disconnect() -> Bool {
        self.cancelDisconnectTimer()
        transmitter.stopScanning()
        sendReceiverEvent(ReceiverEventCode.disconnected, withLatestReading: latestReading)
        return true
    }


    fileprivate func cancelDisconnectTimer(){
        if(nil != disconnectTimer){
            disconnectTimer?.invalidate()
            disconnectTimer = nil
        }
    }

    fileprivate func resetDisconnectTimer(){
        self.cancelDisconnectTimer()
        disconnectTimer = Timer.scheduledTimer(timeInterval: xDripG5Timeout, target: self, selector: #selector(xDripG5Receiver.handleDisconnect), userInfo: nil, repeats: false)
    }

    func handleDisconnect(){
        sendReceiverEvent(ReceiverEventCode.lost_CONNECTION, withLatestReading: latestReading)
    }

    func transmitter(_ transmitter: Transmitter, didRead glucose: Glucose){
        let reading = Reading(value:glucose.glucoseMessage.glucose, timestamp:Date())
        latestReading = reading
        self.resetDisconnectTimer()
        self.sendReceiverEvent(ReceiverEventCode.connected_LAST_READING_GOOD, withLatestReading: latestReading)
    }

    func transmitter(_ transmitter: Transmitter, didError error: Error){
        self.resetDisconnectTimer()
        self.sendReceiverEvent(ReceiverEventCode.connected_LAST_READING_ERROR, withLatestReading: latestReading)
    }

    func transmitter(_ transmitter: Transmitter, didReadUnknownData data: Data) {
        // TODO:
        assertionFailure("Implement me.")
    }

    func sendReceiverEvent(_ eventCode: ReceiverEventCode, withLatestReading: Reading?){
        if(nil != notifier){
            notifier!.receiver(self, hadEvent: eventCode, withLatestReading: withLatestReading)
        }
    }
}
