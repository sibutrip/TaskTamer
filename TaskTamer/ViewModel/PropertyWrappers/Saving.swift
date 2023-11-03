//
//  Saving.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/12/23.
//

import Foundation
import SwiftUI

@propertyWrapper
struct Saving<T:Codable>: DynamicProperty {
    var projectedValue: [T] = []
    var wrappedValue: [T] {
        mutating get {
            if projectedValue.isEmpty {
                let models: [T] = (try? DirectoryService.readModelFromDisk()) ?? []
                self.projectedValue = models
            }
            return projectedValue
        }
        set {
            self.projectedValue = newValue
            DirectoryService.writeModelToDisk(projectedValue)
        }
    }
}
