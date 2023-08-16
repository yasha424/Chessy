//
//  View+Extension.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 11.07.2023.
//

import SwiftUI

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(
        rawValue: "deviceDidShakeNotification"
    )
}

extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(
                for: UIDevice.deviceDidShakeNotification
            )) { _ in
                self.action()
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }

    func glassView(cornerRadius: CGFloat = 14) -> some View {
        return self
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .shadow(color: .white.opacity(0.9), radius: 2, x: -1, y: -2)
            .shadow(color: .black.opacity(0.6), radius: 2, x: 2, y: 2)
    }

    func customBackground() -> some View {
        return self
            .background(.thinMaterial)
            .background(
                LinearGradient(
                    colors: [.blue, .yellow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                ignoresSafeAreaEdges: .all
            )
    }
}
