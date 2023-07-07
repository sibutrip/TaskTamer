//
//  ViewModel+TimeBlocks.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import Foundation

extension ViewModel {
    public func resetTimeBlocks() {
        morningStartTime = DateComponents.hourAndMinute(from: 8, and: 0).date!
        morningEndTime = DateComponents.hourAndMinute(from: 12, and: 0).date!
        afternoonStartTime = DateComponents.hourAndMinute(from: 13, and: 0).date!
        afternoonEndtime = DateComponents.hourAndMinute(from: 17, and: 0).date!
        eveningStartTime = DateComponents.hourAndMinute(from: 17, and: 0).date!
        eveningEndTime = DateComponents.hourAndMinute(from: 21, and: 0).date!
    }
}
