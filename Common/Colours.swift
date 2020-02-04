//
//  Colours.swift
//  It's Complicated
//
//  Created by James Smith on 1/2/20.
//  Copyright © 2020 James Smith. All rights reserved.
//

import UIKit

class Colors {
    static let colors:[(UIColor, String)] = [
        (UIColor(red: 242/255, green: 244/255, blue: 255/255, alpha: 1), "White"),
        (UIColor(red: 250/255, green: 17/255, blue: 79/255, alpha: 1), "Red"),
        (UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1), "Orange"),
        (UIColor(red: 255/255, green: 230/255, blue: 32/255, alpha: 1), "Yellow"),
        (UIColor(red: 4/255, green: 222/255, blue: 113/255, alpha: 1), "Green"),
        (UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1), "Light Blue"),
        (UIColor(red: 32/255, green: 148/255, blue: 250/255, alpha: 1), "Blue"),
        (UIColor(red: 120/255, green: 122/255, blue: 255/255, alpha: 1), "Violet"),
    ]
    
    static var names:[String] {
        return colors.map({ (_, name) -> String in
            return name
        })
    }
    
    static func color(namedBy name:String) -> UIColor? {
        for (color, colorName) in colors {
            if name == colorName {
                return color
            }
        }
        
        return nil
    }
    
    static func indexOf(colorName:String) -> Int? {
        return colors.firstIndex(where: { (color, name) -> Bool in
            if (name == colorName) {
                return true
            }
            return false
        })
    }
}
