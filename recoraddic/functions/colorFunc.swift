//
//  adjustColor.swift
//  recoraddic
//
//  Created by 김지호 on 1/24/24.
//

import Foundation
import SwiftUI

extension Color { // hue: 색조 , saturation: 채도
    func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
        let uiColor = UIColor(self)
        var currentHue: CGFloat = 0
        var currentSaturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var currentOpacity: CGFloat = 0

        if uiColor.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrightness, alpha: &currentOpacity) {
            return Color(hue: currentHue + hue, saturation: currentSaturation + saturation, brightness: currentBrightness + brightness, opacity: currentOpacity + opacity)
        }
        print("oh....")
        return self
    }
    func getRGBA() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            r = r > 1.0 ? 1.0 : r
            g = g > 1.0 ? 1.0 : g
            b = b > 1.0 ? 1.0 : b
            return (r,g,b,a)
        }
        else {
            return (0,0,0,0)
        }
    }
}


func getShadowColor(_ colorScheme:ColorScheme) -> Color {
    return colorScheme == .light ? .black.adjust(brightness:0.2) : .white.adjust(brightness:-0.2)

}

func getColorSchemeColor(_ colorScheme:ColorScheme) -> Color {
    return colorScheme == .light ? .white : .black
}

func getReversedColorSchemeColor(_ colorScheme:ColorScheme) -> Color {
    return colorScheme == .light ? .black : .white
}
