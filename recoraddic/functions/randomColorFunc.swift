//
//  randomColorFunc.swift
//  recoraddic
//
//  Created by 김지호 on 11/14/23.
//

import Foundation
import SwiftUI

func randomColor() -> Color {
    let red = Double.random(in: 0...1)
    let green = Double.random(in: 0...1)
    let blue = Double.random(in: 0...1)
    return Color(red: red, green: green, blue: blue)
}
