//
//  ViewController.swift
//  glucose-badge
//
//  Created by Dennis Gove on 12/5/15.
//  Copyright © 2015 gove. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var transmitterIdField: UITextField!
    @IBOutlet weak var mostRecentValue: UILabel!
    @IBOutlet weak var atTime: UILabel!
    @IBOutlet weak var note: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        transmitterIdField.text = UserDefaults.standard.transmitterId
        AppDelegate.sharedDelegate.initializeReceiver(transmitterIdField.text!)

        transmitterIdField.delegate = self

        note.numberOfLines = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func handleReceiverEvent(_ eventCode: ReceiverEventCode, withLatestReading: Reading?){
        let mydateFormatter = DateFormatter()
        mydateFormatter.calendar = Calendar(identifier: .iso8601)
        mydateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss xx"
        mydateFormatter.locale = Locale(identifier: "en_US_POSIX")

        switch(eventCode){
        case ReceiverEventCode.connected_LAST_READING_GOOD:
            note.text = "We're all good (I think)"
            note.textColor = UIColor.blue
            mostRecentValue.text = String(withLatestReading!.value)
            atTime.text = mydateFormatter.string(from: withLatestReading!.timestamp as Date)
            break

        case ReceiverEventCode.connected_WAITING_FOR_FIRST_READING:
            note.text = "Connected and waiting for first reading"
            note.textColor = UIColor.magenta
            mostRecentValue.text = "Waiting..."
            atTime.text = mydateFormatter.string(from: Date())
            break

        case ReceiverEventCode.connected_LAST_READING_ERROR:
            note.text = "Last reading was an error\n"
            note.textColor = UIColor.red
            mostRecentValue.text = "!Receiver Error!..."
            atTime.text = mydateFormatter.string(from: Date())
            break

        case ReceiverEventCode.disconnected:
            note.text = "We are disconnected"
            note.textColor = UIColor.brown
            mostRecentValue.text = "Disconnected..."
            atTime.text = mydateFormatter.string(from: Date())

        case ReceiverEventCode.lost_CONNECTION:
            note.text = "Connection Lost..."
            note.textColor = UIColor.red
            mostRecentValue.text = "Lost..."
            atTime.text = mydateFormatter.string(from: Date())
        }

        if(nil != withLatestReading){
            note.text! += "\nThe last received reading was " + String(withLatestReading!.value) + " at " + mydateFormatter.string(from: withLatestReading!.timestamp as Date)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        AppDelegate.sharedDelegate.initializeReceiver(transmitterIdField.text!)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

