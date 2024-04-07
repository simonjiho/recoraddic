


import Foundation
import SwiftUI

extension StoneTower_0 {
    
    static let oneQuestion:[String] = [""]
    static let twoQuestions:[String] = ["", ""]
    static let threeQuestions:[String] = ["","",""]


    
    static func calculateVisualValue1(qVal1: Int?, qVal2: Int?, qVal3: Int?) -> Int { //모양
        return 0
    }
    
    static func calculateVisualValue2(qVal1: Int?, qVal2: Int?, qVal3: Int?) -> Int { // 색
        
        return 0

    }
    
    
    static func calculateVisualValue3(qVal1: Int?, qVal2: Int?, qVal3: Int?) -> Int { // 다음 포지션
        return 0

    }
    
    
    static func getDailyRecordColor(index:Int) -> Color {
        if index == 0 {
            return Color.white // almost zero
        }
        else if index == 1 {
            return Color.pink.adjust(saturation:-0.45, brightness: 0.4) // 0.14(o) 0.068(x)
        }
        else if index == 2 {
            return Color.blue.adjust(hue:0.05, saturation:-0.5, brightness: 0.4) // 0.475(o) 0.36(x)
        }
        else if index == 3 {
            return Color.green.adjust(hue:-0.1, saturation:-0.45, brightness: 0.3) // 0.354(o)   0.35(x)
        }
        else if index == 4 {
            return Color.purple.adjust(hue:-0.05, saturation:-0.4, brightness: 0.3) // 0.1(o)  0.03(not that good)
        }
        else if index == 5 {
            return Color.orange.adjust(hue:-0.04, saturation:-0.4, brightness: 0.5) //      0.37
        }
        else {
            return Color.white
        }
    }
    
    
}
