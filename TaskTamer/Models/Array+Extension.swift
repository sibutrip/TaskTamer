//
//  Array+Extension.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 9/5/25.
//

extension Array where Element: Identifiable {
    mutating func replace(with updates: [Element]) {
        let byID = Dictionary(uniqueKeysWithValues: updates.map { ($0.id, $0) })
        for i in indices {
            if let u = byID[self[i].id] { self[i] = u }
        }
    }
}
