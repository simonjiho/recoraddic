//
//  Text_scaleToFit.swift
//  recoraddic
//
//  Created by 김지호 on 8/28/24.
//

import Foundation
import SwiftUI


struct Text_scaleToFit: View {
    var text: String
    init(_ text: String) {
        self.text = text
    }
    var body: some View {
        Text(text)
            .minimumScaleFactor(0.2)
    }
}
