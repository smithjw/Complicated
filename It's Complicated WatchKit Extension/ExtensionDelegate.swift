//
//  ExtensionDelegate.swift
//  It's Complicated WatchKit Extension
//
//  Created by James Smith on 1/2/20.
//  Copyright © 2020 James Smith. All rights reserved.
//

import WatchKit
import Foundation

let userDefaults = UserDefaults.standard
extension UserDefaults {

    func valueExists(forKey key: String) -> Bool {
        return object(forKey: key) != nil
    }

}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    var scheduledBackgroundTask = false
    
    static func scheduleComplicationUpdate() {
        let currentDate = Date()
        let scheduleDate = currentDate + TimeInterval(ComplicationController.minutesPerTimeline * 60)
        print("Scheduling background refresh task at \(currentDate) for: \(scheduleDate)")
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: scheduleDate, userInfo: nil) { (error) in
            if let err = error {
                print("Failed to schedule background refresh: \(err)")
            }
        }
    }
    
    static func reloadComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        guard let complications = complicationServer.activeComplications else { return }
        for complication in complications {
            print("Updating Complication")
            complicationServer.reloadTimeline(for: complication)
        }
    }

    func applicationDidFinishLaunching() {
        
        // Sets Large Text switch value to true
        if !userDefaults.valueExists(forKey: "LargeText") {
            userDefaults.set(true, forKey: "LargeText")
        }
        print("ExtensionDelegate applicationDidFinishLaunching()")

    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        ExtensionDelegate.reloadComplications()
        print("ExtensionDelegate applicationDidBecomeActive")
        
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state.
        ExtensionDelegate.reloadComplications()
        print("ExtensionDelegate applicationWillResignActive")
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                ExtensionDelegate.reloadComplications()
                ExtensionDelegate.scheduleComplicationUpdate()
                scheduledBackgroundTask = true
                
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                print("BACKGROUND: WKSnapshotRefreshBackgroundTask")
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                print("BACKGROUND: WKWatchConnectivityRefreshBackgroundTask")
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                print("BACKGROUND: WKURLSessionRefreshBackgroundTask")
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                print("BACKGROUND: WKRelevantShortcutRefreshBackgroundTask")
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                print("BACKGROUND: WKIntentDidRunRefreshBackgroundTask")
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                print("BACKGROUND: \(task.classForCoder.description())")
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}

extension Notification.Name {
    static let refresh = Notification.Name("refresh")
}
