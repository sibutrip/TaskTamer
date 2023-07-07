//
//  Bool+Extension.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/6/23.
//

import Foundation

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}
