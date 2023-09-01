//
//  comboStone.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/17.
//

import Foundation
import SwiftUI

// create it as metal later...


struct ComboStone_default: View {
    var combo: Int
    var color: Color!
    
    init(_ input: Int) {
        combo = input
        color = getColor(input)
    }
    
    func getColor(_ combo: Int) -> Color {
        switch combo {
        case 0:
            return Color.black
        case 1:
            return Color.gray
        case 2:
            return Color.red
        case 3:
            return Color.orange
        case 4:
            return Color.yellow
        case 5:
            return Color.mint
        case 6:
            return Color.green
        case 7:
            return Color.cyan
        case 8:
            return Color.blue
        case 9:
            return Color.indigo
        case 10:
            return Color.purple
        case 11:
            return Color.pink
        case 12:
            return Color.teal
        default:
            return Color.white
        // 20개 정도는 만들어야 함
        }
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width:30,height:30)
    }
}
