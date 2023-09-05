//
//  HapticFeedbackService.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 31.08.2023.
//

import Foundation
import UIKit

class HapticFeedbackService {

    static let instance = HapticFeedbackService()

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
