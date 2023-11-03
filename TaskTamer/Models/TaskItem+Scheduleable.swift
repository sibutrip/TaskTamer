//
//  TaskItem+Scheduleable.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 10/31/23.
//

import Foundation

protocol Scheduleable {
    
    /// The title for the calendar item.
    var eventTitle: String { get }
    
    /// The start time of the task
    var startDate: Date? { get set }
    
    /// The end time of the task
    var endDate: Date? { get set }
    
    /// The unique ID of the event from the event's EKEventStore
    var eventID: String? { get set }
}
