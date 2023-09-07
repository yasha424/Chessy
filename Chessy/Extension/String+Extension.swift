//
//  String+Extension.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 06.09.2023.
//

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    subscript (idx: Int) -> String {
        String(self[self.index(startIndex, offsetBy: idx)])
    }
}
