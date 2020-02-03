//
//  ComplicationController.swift
//  It's Complicated WatchKit Extension
//
//  Created by James Smith on 1/2/20.
//  Copyright © 2020 James Smith. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    static let minutesPerTimeline = 5
    
    override init() {
        print("ComplicationController init()")
        
        ExtensionDelegate.scheduleComplicationUpdate()
    }
    
    deinit {
        print("ComplicationController deinit()")
    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    private var configuredColor:UIColor {
        var color:UIColor = .white
        if let timeColorName = UserDefaults.standard.object(forKey: "TimeColor") as? String {
            if let timeColor = Colors.color(namedBy: timeColorName) {
                color = timeColor
            }
        }
        
        return color
    }
    
//    private var largeText:Bool {
//        if let largeTextValue = UserDefaults.standard.object(forKey: "LargeText") as? Bool {
//            if let largeText = Colors.color(namedBy: timeColorName) {
//                color = timeColor
//            }
//        }
//        
//        return largeText
//    }
    
    private func createDayTextProvider(from date:Date) -> CLKSimpleTextProvider {
        let dayOfMonth = Calendar.current.component(.day, from: date)
        let dayProvider = CLKSimpleTextProvider(text: "\(dayOfMonth)", shortText: "\(dayOfMonth)")
        
        return dayProvider
    }
    
    private func createWeekdayTextProvider(from date:Date) -> CLKSimpleTextProvider {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let dayInWeek = dateFormatter.string(from: date)
        
        let weekdayProvider = CLKSimpleTextProvider(text: "\(dayInWeek)", shortText: "\(dayInWeek)")
        
        let color = self.configuredColor
        weekdayProvider.tintColor = color
        
        return weekdayProvider
    }
    
    private func createMonthDayTextProvider(from date:Date) -> CLKSimpleTextProvider {
        let dateFormat = DateFormatter()
        let numberFormat = NumberFormatter()
        dateFormat.dateFormat = "MMM"
        numberFormat.numberStyle = .ordinal
        let calendar = Calendar.current
        let date = Date()
        let dateComponents = calendar.component(.day, from: date)
        let day = numberFormat.string(from: dateComponents as NSNumber)

        let today = CLKSimpleTextProvider(text: "\(dateFormat.string(from: date)) \(day!)")
    
        return today
    }
    
//    private func createGaugeTemplate(from date:Date) -> CLKComplicationTemplateGraphicCircularClosedGaugeText {
//        let dayProvider = createDayTextProvider(from: date)
//        let guageProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: self.configuredColor, fillFraction: 1.0)
//
//        let gaugeTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText()
//        gaugeTemplate.centerTextProvider = dayProvider
//        gaugeTemplate.gaugeProvider = guageProvider
//
//        return gaugeTemplate
//    }
    
    private func createGaugeTemplate(from date:Date) -> CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText {
        let dayProvider = createDayTextProvider(from: date)
        let weekdayProvider = createWeekdayTextProvider(from: date)
        let guageProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColors: [.cyan, .blue], gaugeColorLocations: nil, fillFraction: 1.0)
        
        let gaugeTemplate = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
        gaugeTemplate.centerTextProvider = dayProvider
        gaugeTemplate.bottomTextProvider = weekdayProvider
        gaugeTemplate.gaugeProvider = guageProvider
        
        return gaugeTemplate
    }
    
    private func createBezelCircularTextTemplate(from date:Date) -> CLKComplicationTemplate {
        let gaugeTemplate = createGaugeTemplate(from: date)
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        
        let textProvider = CLKTimeTextProvider(date: date)
        template.textProvider = textProvider
        template.circularTemplate = gaugeTemplate
        
        return template
    }
    
    func createGraphicCornerTemplate(from date:Date) -> CLKComplicationTemplate {
        
        let color = self.configuredColor
        
        let timeProvider = CLKTimeTextProvider(date: date)
        timeProvider.tintColor = color
        
//        if UserDefaults.standard.object(forKey: "LargeText") as? Bool ?? true {
        if UserDefaults.standard.bool(forKey: "LargeText") {
            // Using a Gauge in the corner complication rather than the Stack text results in the time display being more readable
            // Could set the gauge to another colour, but setting as Black so it's not shown
            let gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .black, fillFraction: 1.0)
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = timeProvider
            template.gaugeProvider = gaugeProvider
            
            return template
        
        } else {
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.outerTextProvider = timeProvider
            template.innerTextProvider = createMonthDayTextProvider(from: date)
            
            return template
        
        }
    }
    
    func buildTemplate(for complication: CLKComplication, at date:Date) -> CLKComplicationTemplate? {
        var template:CLKComplicationTemplate? = nil
        switch complication.family {
        case .graphicCorner:
            template = createGraphicCornerTemplate(from: date)
        case .graphicBezel:
            template = createBezelCircularTextTemplate(from: date)
        case .graphicCircular:
            template = createGaugeTemplate(from: date)
        
        @unknown default:
            print("Ummmmm")
        }
        
        return template
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        let currentDate = Date.init()
        guard let template = buildTemplate(for: complication, at: currentDate) else { handler(nil); return }
        
        let entry = CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: template)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        
        var entries:[CLKComplicationTimelineEntry] = []
        var currentDate = date
        
        var nextMinute = currentDate.timeIntervalSince1970
        nextMinute = 60 - nextMinute.truncatingRemainder(dividingBy: 60)
        currentDate = currentDate + nextMinute + 1
        
        let realLimit = (limit > ComplicationController.minutesPerTimeline) ? ComplicationController.minutesPerTimeline : limit
        
        while (entries.count < realLimit) {
            guard let template = buildTemplate(for: complication, at: currentDate) else { continue }
            let entry = CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: template)
            entries.append(entry)
            currentDate = currentDate + 60
        }
        
        handler(entries)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let currentDate = Date.init()
        let template = buildTemplate(for: complication, at: currentDate)
        
        handler(template)
    }
    
}
