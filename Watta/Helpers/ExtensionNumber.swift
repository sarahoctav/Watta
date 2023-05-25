//
//  ExtensionNumber.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import Foundation

extension Double {
    func twoTrailingZero() -> String {
        return String(format: "%.2f", self)
    }
    func noTrailingZero() -> String {
        return String(format: "%.0f", self)
    }
}

extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
