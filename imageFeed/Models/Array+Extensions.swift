//
//  Array+Extensions.swift
//  imageFeed
//
//  Created by Medina Huseynova on 06.05.25.
//

import Foundation

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}

