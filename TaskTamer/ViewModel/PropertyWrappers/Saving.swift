//
//  Saving.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/12/23.
//

import Foundation
import SwiftUI

@propertyWrapper
struct Saving<T:Encodable>: DynamicProperty {
    var projectedValue: [T] = []
    var wrappedValue: [T] {
        get {
            return projectedValue
        }
        set {
            self.projectedValue = newValue
            DirectoryService.writeModelToDisk(projectedValue)
        }
    }
}
