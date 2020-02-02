//
//  Unused.swift
//  It's Complicated WatchKit Extension
//
//  Created by James Smith on 1/2/20.
//  Copyright © 2020 James Smith. All rights reserved.
//

import Foundation


private func createModularSmallTemplate(from date:Date) -> CLKComplicationTemplate {
    let provider = CLKTimeTextProvider(date: date)
    provider.tintColor = self.configuredColor

    let template = CLKComplicationTemplateModularSmallSimpleText()
    template.textProvider = provider
    return template
}

private func createModularLargeTemplate(from date:Date) -> CLKComplicationTemplate {
    let color = self.configuredColor
    let timeProvider = CLKTimeTextProvider(date: date)
    timeProvider.tintColor = color
    
    let dateProvider = CLKDateTextProvider(date: date, units: .day)
    dateProvider.tintColor = color
    
    let template = CLKComplicationTemplateModularLargeStandardBody()
    template.headerTextProvider = dateProvider
    template.body1TextProvider = timeProvider
    return template
}

private func createUtilitarianSmallTemplate(from date:Date) -> CLKComplicationTemplate {
    let template = CLKComplicationTemplateUtilitarianSmallRingText()
    template.textProvider = createDayTextProvider(from: date)
    template.tintColor = self.configuredColor
    template.ringStyle = .closed
    template.fillFraction = 1.0
    
    return template
}

func createUtilitarianSmallFlatTemplate(from date:Date) -> CLKComplicationTemplate {
    let provider = CLKTimeTextProvider(date: date)
    provider.tintColor = self.configuredColor
    
    let template = CLKComplicationTemplateUtilitarianSmallFlat()
    template.textProvider = provider
    return template
}

func createUtilitarianLargeTemplate(from date:Date) -> CLKComplicationTemplate {
    let provider = CLKTimeTextProvider(date: date)
    provider.tintColor = self.configuredColor
    
    let template = CLKComplicationTemplateUtilitarianLargeFlat()
    template.textProvider = provider
    return template
}

func createExtaLargeTemplate(from date:Date) -> CLKComplicationTemplate {
    let template = CLKComplicationTemplateExtraLargeRingText()
    template.textProvider = createDayTextProvider(from: date)
    template.tintColor = self.configuredColor
    template.ringStyle = .closed
    template.fillFraction = 1.0
    
    return template
}

func createCircularSmallTemplate(from date:Date) -> CLKComplicationTemplate {
    let template = CLKComplicationTemplateCircularSmallRingText()
    template.textProvider = createDayTextProvider(from: date)
    template.tintColor = self.configuredColor
    template.ringStyle = .closed
    template.fillFraction = 1.0
    
    return template
}

func createGraphicRectangularTemplate(from date:Date) -> CLKComplicationTemplate {
    
    let color = self.configuredColor
    
    let dateProvider = CLKDateTextProvider(date: date, units: .day)
    dateProvider.tintColor = color
    let timeProvider = CLKTimeTextProvider(date: date)
    timeProvider.tintColor = color
    let gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: color, fillFraction: 1.0)
    
    let template = CLKComplicationTemplateGraphicRectangularTextGauge()
    template.headerTextProvider = dateProvider
    template.body1TextProvider = timeProvider
    template.gaugeProvider = gaugeProvider
    
    return template
}
