//
//  DismissKeyboard.swift
//  recoraddic
//
//  Created by 김지호 on 1/12/24.
//

import Foundation
import SwiftUI

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .map { $0 as? UIWindowScene }
                    .compactMap { $0 }
                    .first?.windows
                    .filter { $0.isKeyWindow }.first
                print( keyWindow == nil)
                keyWindow?.endEditing(true)
            }
    }
}


extension View {
    func dismissingKeyboard() -> some View {
        modifier(DismissingKeyboard())
    }
}

func dismissKeyboard_func() -> Void {
    let keyWindow = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .map { $0 as? UIWindowScene }
        .compactMap { $0 }
        .first?.windows
//        .filter { $0.isKeyWindow }.first
        .filter { $0.isKeyWindow }.first

    keyWindow?.endEditing(true)
}
