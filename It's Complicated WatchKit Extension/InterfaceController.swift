//
//  InterfaceController.swift
//  It's Complicated WatchKit Extension
//
//  Created by James Smith on 1/2/20.
//  Copyright © 2020 James Smith. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
    @IBOutlet weak var outerGroup: WKInterfaceGroup!
    @IBOutlet weak var colourPicker: WKInterfacePicker!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        refreshContent()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NotificationCenter.default.removeObserver(self)
        super.didDeactivate()
    }
    
    @objc func refreshContent() {
        // Configure interface objects here.
        let dateFormat = DateFormatter()
        let numberFormat = NumberFormatter()
        dateFormat.dateFormat = "MMM"
        numberFormat.numberStyle = .ordinal
        let calendar = Calendar.current
        let date = Date()
        let dateComponents = calendar.component(.day, from: date)
        let day = numberFormat.string(from: dateComponents as NSNumber)

        let today = "\(dateFormat.string(from: date)) \(day!)"
        dateLabel.setText("\(today)")
        
        // Get the colour from UserDefaults
        var currentColourIndex = 0
        if let currentColourName = UserDefaults.standard.object(forKey: "UserColour") as? String {
            if let index = Colors.indexOf(colorName: currentColourName) {
                currentColourIndex = index
            }
            
            if let colour = Colors.color(namedBy: currentColourName) {
                dateLabel.setTextColor(colour)
            }
        }
        
        let pickerItems = Colors.names.map { (name) -> WKPickerItem in
            let item = WKPickerItem()
            item.title = name
            return item
        }
        colourPicker.setItems(pickerItems)
        colourPicker.setSelectedItemIndex(currentColourIndex)
    }
    @IBAction func setLargeBezelText(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "LargeText")
        Log.d("Large Text: \(value)")
        ExtensionDelegate.reloadComplications()
    }
    
    @IBAction func colourPickerAction(_ value: Int) {
        let (colour, name) = Colors.colors[value]
        
        dateLabel.setTextColor(colour)
        
        UserDefaults.standard.set(name, forKey: "UserColour")
        Log.d("Colour: \(value)")
        ExtensionDelegate.reloadComplications()
        
        
    }
}
