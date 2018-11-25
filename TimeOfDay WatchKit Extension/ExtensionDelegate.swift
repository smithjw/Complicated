//
//  ExtensionDelegate.swift
//  TimeOfDay WatchKit Extension
//
//  Created by Nick Rogness on 11/23/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import WatchKit

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

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        print("ExtensionDelegate applicationDidFinishLaunching()")
        
        // start the background update.  This is only called when the app actually starts, so we need to
//        if (!scheduledBackgroundTask) {
//            ExtensionDelegate.scheduleComplicationUpdate()
//            scheduledBackgroundTask = true
//        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("ExtensionDelegate applicationDidBecomeActive")
        
        
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
               
                let complicationServer = CLKComplicationServer.sharedInstance()
                for complication in complicationServer.activeComplications! {
                    print("UPDATE COMPLICATION")
                    complicationServer.reloadTimeline(for: complication)
                }
                
                ExtensionDelegate.scheduleComplicationUpdate()
                scheduledBackgroundTask = true
                
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
