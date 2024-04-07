//
//  ResizableText.swift
//  recoraddic
//
//  Created by 김지호 on 12/3/23.
//

import Foundation
import SwiftUI

// caution: size of each character varies.
// 나중에 글자별로 크기 비율 다 정리하기


struct ResizableText_Width: View {
    var text: String
    var width: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: fontSize(for: text)))
    }

    private func fontSize(for text: String) -> CGFloat {
        let length = text.count
        return width/CGFloat(length)*1.3
    }
}

struct ResizableText_Height: View {
    var text: String
    var height: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: height))
    }


}

struct ResizableText: View {
    var text: String
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: min(fontSize(for: text), height)))
    }

    private func fontSize(for text: String) -> CGFloat {
        let length = text.count
        return width/CGFloat(length)*1.3
    }
}
