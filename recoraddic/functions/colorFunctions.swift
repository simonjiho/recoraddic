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

func purposeColor(purpose:String) -> Color {
    switch purpose {
    case DefaultPurpose.atr: return Color(red: 255.0/255.0, green: 251.0/255.0, blue: 13.0/255.0)
    case DefaultPurpose.hlt: return Color(red: 255.0/255.0, green: 53.0/255.0, blue: 87.0/255.0)
//    case DefaultPurpose.ftr: return Color(red: 247.0/255.0, green: 201.0/255.0, blue: 255.0/255.0)
    case DefaultPurpose.ftr: return Color(red: 210.0/255.0, green: 170.0/255.0, blue: 255.0/255.0)
    case DefaultPurpose.ent: return Color(red: 255.0/255.0, green: 204.0/255.0, blue: 51.0/255.0)
    case DefaultPurpose.rts: return Color(red: 184.0/255.0, green: 78.0/255.0, blue: 241.0/255.0)
    case DefaultPurpose.inq: return Color(red: 110.0/255.0, green: 187.0/255.0, blue: 255.0/255.0)
    case DefaultPurpose.ach: return Color(red: 107.0/255.0, green: 107.0/255.0, blue: 107.0/255.0)
    case DefaultPurpose.cmp: return Color(red: 255.0/255.0, green: 125.0/255.0, blue: 31.0/255.0)
    case DefaultPurpose.lov: return Color(red: 255.0/255.0, green: 179.0/255.0, blue: 215.0/255.0)
    case DefaultPurpose.fml: return Color(red: 255.0/255.0, green: 36.0/255.0, blue: 168.0/255.0)
    case DefaultPurpose.cmn: return Color(red: 0.0/255.0, green: 152.0/255.0, blue: 56.0/255.0)
    case DefaultPurpose.alt: return Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0)
    case DefaultPurpose.wrl: return Color(red: 138.0/255.0, green: 255.0/255.0, blue: 102.0/255.0)
    default: return .clear
    }
}


#Preview(body: {
    VStack {
        ForEach(defaultPurposes, id: \.self) { purpose in
            purposeColor(purpose: purpose)
        }

    }
})
