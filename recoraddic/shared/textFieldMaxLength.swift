//
//  textFieldMaxLength.swift
//  recoraddic
//
//  Created by 김지호 on 12/20/23.
//

import Foundation
import SwiftUI

struct TextFieldMaxLengthModifier: ViewModifier {
    @Binding var text: String
    let maxLength: Int

    func body(content: Content) -> some View {
        content
            .onChange(of:text) {
                if text.count > maxLength {
                    text = String(text.prefix(maxLength))
                }
            }
    }
}

extension View {
    func maxLength(_ maxLength: Int, text: Binding<String>) -> some View {
        self.modifier(TextFieldMaxLengthModifier(text: text, maxLength: maxLength))
    }
}
