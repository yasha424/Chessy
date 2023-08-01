//
//  EnvironmentValues+Extension.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 02.08.2023.
//

import SwiftUI

private struct ShouldRotateKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var shouldRotate: Bool {
        get { self[ShouldRotateKey.self] }
        set { self[ShouldRotateKey.self] = newValue }
    }
}
