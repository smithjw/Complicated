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
    
    private var configuredColour:UIColor {
        var colour:UIColor = .white
        // If colour has been set by the user in the app, use that otherwise default to white
        if let UserColourName = UserDefaults.standard.object(forKey: "UserColour") as? String {
            if let UserColour = Colors.color(namedBy: UserColourName) {
                colour = UserColour
            }
        }
        
        return colour
    }
    
    // MARK: - Setup Date and Time Variables
    
    private func createDayTextProvider(from date:Date) -> CLKDateTextProvider {
//        let dayOfMonth = Calendar.current.component(.day, from: date)
//        let dayProvider = CLKSimpleTextProvider(text: "\(dayOfMonth)", shortText: "\(dayOfMonth)")
        
        let dayProvider = CLKDateTextProvider(date: Date(), units: .day)
        
        return dayProvider
    }
    
    private func createWeekdayTextProvider(from date:Date) -> CLKSimpleTextProvider {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let dayInWeek = dateFormatter.string(from: date)

        let weekdayProvider = CLKSimpleTextProvider(text: "\(dayInWeek)", shortText: "\(dayInWeek)")
        
        let colour = self.configuredColour
        weekdayProvider.tintColor = colour
        
        return weekdayProvider
    }
    
    private func createWeekdayDayTextProvider(from date:Date) -> CLKDateTextProvider {
//        let dateFormat = DateFormatter()
//        let numberFormat = NumberFormatter()
//        dateFormat.dateFormat = "MMM"
//        numberFormat.numberStyle = .ordinal
//        let calendar = Calendar.current
//        let date = Date()
//        let dateComponents = calendar.component(.day, from: date)
//        let day = numberFormat.string(from: dateComponents as NSNumber)

        let today = CLKDateTextProvider(date: Date(), units: [.weekday, .day, .month])
    
        return today
    }
    

    private func createGaugeStackTextTemplate(from date:Date) -> CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText {
        let colour = self.configuredColour
        let dayProvider = createDayTextProvider(from: date)
        let weekdayProvider = createWeekdayTextProvider(from: date)
        let guageProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: colour, fillFraction: CLKSimpleGaugeProviderFillFractionEmpty)
        
        let gaugeTemplate = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
        gaugeTemplate.centerTextProvider = dayProvider
        gaugeTemplate.bottomTextProvider = weekdayProvider
        gaugeTemplate.gaugeProvider = guageProvider
        
        return gaugeTemplate
    }
    
    private func createStackTextTemplate(from date:Date) -> CLKComplicationTemplateGraphicCircularStackText {
        let dayProvider = createDayTextProvider(from: date)
        let weekdayProvider = createWeekdayTextProvider(from: date)
        
        let stackTextTemplate = CLKComplicationTemplateGraphicCircularStackText()
        stackTextTemplate.line1TextProvider = weekdayProvider
        stackTextTemplate.line2TextProvider = dayProvider
        
        return stackTextTemplate
    }
    
    private func createBezelCircularTextTemplate(from date:Date) -> CLKComplicationTemplate {
        let circleTemplate = createStackTextTemplate(from: date)
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        
        let textProvider = CLKTimeTextProvider(date: date)
        template.textProvider = textProvider
        template.circularTemplate = circleTemplate
        
        return template
    }
    
    func createGraphicCornerTemplate(from date:Date) -> CLKComplicationTemplate {
        
        let colour = self.configuredColour
        let largeText = UserDefaults.standard.bool(forKey: "LargeText")
        let timeProvider = CLKTimeTextProvider(date: date)
        timeProvider.tintColor = colour
        
        if largeText {
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
            template.innerTextProvider = createWeekdayDayTextProvider(from: date)
            
            return template
        
        }
    }
    
    func buildTemplate(for complication: CLKComplication, at date:Date) -> CLKComplicationTemplate? {
        var template:CLKComplicationTemplate? = nil
        switch complication.family {
        case .graphicCorner:
            // Corner complications on the Infograph face
            template = createGraphicCornerTemplate(from: date)
        case .graphicBezel:
            // Contains text around the bezel of the watch and the top circular complication
            template = createBezelCircularTextTemplate(from: date)
        case .graphicCircular:
            // Used for the three bottom complications on the Infograph face
            // Also used for the circular complications on the Infograph Modular face
            template = createGaugeStackTextTemplate(from: date)
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
    
//    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
//        // Call the handler with the timeline entries prior to the given date
//        handler(nil)
//    }
    
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
        let currentDate = Date()
        let template = buildTemplate(for: complication, at: currentDate)
        
        handler(template)
    }
    
}
