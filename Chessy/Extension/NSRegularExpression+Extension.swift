//
//  NSRegularExpression+Extension.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 06.09.2023.
//

import Foundation

extension NSRegularExpression {

    func splitn(_ str: String, _ n: Int = -1) -> [String] {
        let range = NSRange(location: 0, length: str.utf8.count)
        let matches = self.matches(in: str, range: range)

        var result = [String]()
        if (n != -1 && n < 2) || matches.isEmpty { return [str] }

        if let first = matches.first?.range {
            if first.location == 0 { result.append("") }
            if first.location != 0 {
                let _range = NSRange(location: 0, length: first.location)
                result.append(String(str[Range(_range, in: str)!]))
            }
        }

        for (cur, next) in zip(matches, matches[1...]) {
            let loc = cur.range.location + cur.range.length
            if n != -1 && result.count + 1 == n {
                let _range = NSRange(location: loc, length: str.utf8.count - loc)
                result.append(String(str[Range(_range, in: str)!]))
                return result
            }
            let len = next.range.location - loc
            let _range = NSRange(location: loc, length: len)
            result.append(String(str[Range(_range, in: str)!]))
        }

        if let last = matches.last?.range, !(n != -1 && result.count >= n) {
            let lastIndex = last.length + last.location
            if lastIndex == str.utf8.count { result.append("") }
            if lastIndex < str.utf8.count {
                let _range = NSRange(location: lastIndex, length: str.utf8.count - lastIndex)
                result.append(String(str[Range(_range, in: str)!]))
            }
        }
        return result
    }

}
