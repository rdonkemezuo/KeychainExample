//
//  Date+Extension.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/30/21.
//

import Foundation

extension Date {
    func daysBetweenDates(startDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: self)
        let numberOfDays = components.day ?? 0
        return numberOfDays
    }
}
