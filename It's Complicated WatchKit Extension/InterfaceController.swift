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
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshContent), name: .refresh, object: nil)
        refreshContent()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NotificationCenter.default.removeObserver(self)
        super.didDeactivate()
    }
    
    @objc func refreshContent() {
        // Configure interface objects here.
//        let today = Date()
//        let dateFormat = DateFormatter()
//        let numberFormatter = NumberFormatter()
//
//        numberFormatter.numberStyle = .ordinal
//        dateFormat.dateFormat = "MMM"
//        dateLabel.setText(dateFormat.string(from: today))
        
        
//        -------
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
        
//        ----
        
        // Get the color from UserDefaults
        var currentColorIndex = 0
        if let currentColorName = UserDefaults.standard.object(forKey: "TimeColor") as? String {
            if let index = Colors.indexOf(colorName: currentColorName) {
                currentColorIndex = index
            }
            
            if let color = Colors.color(namedBy: currentColorName) {
                dateLabel.setTextColor(color)
//                outerGroup.setBackgroundColor(color)
            }
        }
        
        let pickerItems = Colors.names.map { (name) -> WKPickerItem in
            let item = WKPickerItem()
            item.title = name
            return item
        }
        colourPicker.setItems(pickerItems)
        colourPicker.setSelectedItemIndex(currentColorIndex)
    }
    @IBAction func setLargeBezelText(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "LargeText")
        print(value)
        ExtensionDelegate.reloadComplications()
    }
    
    @IBAction func colourPickerAction(_ value: Int) {
        let (color, name) = Colors.colors[value]
        
        dateLabel.setTextColor(color)
//        outerGroup.setBackgroundColor(color)
        
        UserDefaults.standard.set(name, forKey: "TimeColor")
        
        ExtensionDelegate.reloadComplications()
        
        
    }
}
