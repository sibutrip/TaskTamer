//
//  DragManager.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/11/23.
//

import Foundation

class DragManager: ObservableObject {
    static var sortDidFail = false
    
    @Published var offset: CGSize = .zero
    
    func zeroOffsets() {
        self._offset = .init(initialValue: .zero)
    }
}
