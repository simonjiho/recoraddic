//
//  viewFrameKey.swift
//  recoraddic
//
//  Created by 김지호 on 4/7/24.
//

import Foundation
import SwiftUI

struct ViewFrameKey: PreferenceKey {
    typealias Value = CGRect
    static var defaultValue = CGRect.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}


extension Notification { // to get keyboardHeight
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
