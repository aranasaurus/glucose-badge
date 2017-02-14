//
//  AppDelegate.swift
//  glucose-badge
//
//  Created by Dennis Gove on 12/5/15.
//  Copyright © 2015 gove. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReceiverNotificationDelegate {

    var window: UIWindow?
    var app: UIApplication!
    var receiver: Receiver?

    static var sharedDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.app = application

        self.resignFirstResponder()

        // Ask user for notification because we're gonna write to the badge
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: UIUserNotificationType.badge, categories: nil))

        // Clear any previous value there
        // This is done in the viewDidLoad method of the ViewController

        return true
    }

    internal func initializeReceiver(_ transmitterId: String){

        if(nil != self.receiver){
            self.receiver?.disconnect()
        }

        UserDefaults.standard.transmitterId = transmitterId
        self.receiver = createReceiver(transmitterId)
        self.receiver?.readingNotifier = self
        self.receiver?.connect()
    }

    fileprivate func createReceiver(_ transmitterId: String) -> Receiver? {

//        return StaticValuesReceiver(
//            readings: [Reading(value:70, timestamp:NSDate()), Reading(value:80, timestamp:NSDate())],
//            valueChangeInterval: 10
//        )

        return xDripG5Receiver(transmitterId: transmitterId)
    }

    func receiver(_ receiver: Receiver, hadEvent: ReceiverEventCode, withLatestReading: Reading?){

        if(nil != withLatestReading && ReceiverEventCode.connected_LAST_READING_GOOD == hadEvent){
            app.applicationIconBadgeNumber = Int(withLatestReading!.value)
        }
        else{
            app.applicationIconBadgeNumber = 0
        }

        let vc = self.window!.rootViewController as! ViewController
        vc.handleReceiverEvent(hadEvent, withLatestReading: withLatestReading)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

