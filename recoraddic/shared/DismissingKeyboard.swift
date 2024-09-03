//
//  DismissKeyboard.swift
//  recoraddic
//
//  Created by 김지호 on 1/12/24.
//

import Foundation
import SwiftUI

struct DismissingKeyboard: ViewModifier {
    
    let condition: Bool
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if condition {
                    let keyWindow = UIApplication.shared.connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .map { $0 as? UIWindowScene }
                        .compactMap { $0 }
                        .first?.windows
                        .filter { $0.isKeyWindow }.first
                    //                print( keyWindow == nil)
                    keyWindow?.endEditing(true)
                }
            }
    }
}


extension View {
    func dismissingKeyboard() -> some View {
        modifier(DismissingKeyboard(condition: true))
    }
    func dismissingKeyboard(_ condition: Bool) -> some View {
        modifier(DismissingKeyboard(condition: condition))
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
