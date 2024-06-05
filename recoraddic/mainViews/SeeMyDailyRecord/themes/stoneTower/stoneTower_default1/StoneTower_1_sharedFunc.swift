//
//  StoneTower_default1_sharedFunc.swift
//  recoraddic
//
//  Created by 김지호 on 1/27/24.
//

import Foundation
import SwiftUI

extension StoneTower_1 {
    
    static let oneQuestion:[String] = ["모양/밝기/위치"]
    static let twoQuestions:[String] = ["모양/밝기", "위치"]
    static let threeQuestions:[String] = ["모양","밝기","위치"]


    
    static func calculateVisualValue1(qVal1: Int?, qVal2: Int?, qVal3: Int?) -> Int { //모양
        
        let inputValue = qVal1! // 무조건 qVal에 의해 결정
        
        if inputValue >= 0 {
            return inputValue
        }
        else {
            return 0
        }
    }
    
    static func calculateVisualValue2(qVal1: Int?, qVal2: Int?, qVal3: Int?) -> Int { // 색
        
        let inputValue:Int = {
            if qVal3 != nil {return qVal2!}
            else {return qVal1!}
        }() // 질문 3개이면 qVal2 반영, 2개이면 모양과 함께 qVal1 반영
        
        return inputValue
    }
    
    
    static func calculateVisualValue3(qVal1: Int?, qVal2: Int?, qVal3: Int?, _ prevPos:Int) -> Int { // 다음 포지션
        
        
        let inputValue:Int = {
            if qVal3 != nil {return qVal3!}
            else if qVal2 != nil {return qVal2!}
            else {return qVal1!}
        }() // 질문 3개 -> qVal3, 질문 2개 -> qVal2, 질문 1개 -> qVal1
        
        

        if inputValue >= 0 {
            return prevPos
        }
        else {

            let oneOrMinusOne:Int = {
                if prevPos - inputValue >= 9 {
                    return 1
                }
                else if prevPos + inputValue <= -9 {
                    return -1
                }
                else {
                    return Int.random(in: 0...1) == 1 ? 1 : -1
                }
                
            }()
            
            return prevPos + oneOrMinusOne * inputValue
        }

    }
    
    static func recalculateVisualValues(dailyRecord:DailyRecord, dailyRecords_savedAndVisible:[DailyRecord], targetIndex:Int, drCount:Int, option:DrEditOption) -> Void {
        switch option {
        case.visible:
            // 1 3 6 -> 1 4 -> 1 3 6
            // 1 3 6 10 -> 1 (3) 4 7 -> 1 3 6 10
            let prevPos:Int = targetIndex == 0 ? 0 : dailyRecords_savedAndVisible[targetIndex-1].visualValue3!
            let newVisualVal3:Int = StoneTower_1.calculateVisualValue3(qVal1: dailyRecord.questionValue1, qVal2: dailyRecord.questionValue2, qVal3: dailyRecord.questionValue3, prevPos)
            dailyRecord.visualValue3 = newVisualVal3
    //        let nextPos:Int = targetIndex == dailyRecords_savedAndUnhidden.count - 1 ? dailyRecords_savedAndUnhidden[targetIndex+1].visualValue3! : 0
    //        let nextPox_Gap: Int =

            let plusVisualValue3: Int = {
                if targetIndex == 0 {
                    return newVisualVal3
                }
                else {
                    return newVisualVal3 - dailyRecords_savedAndVisible[targetIndex-1].visualValue3! // 음 어떻게 할까 이게 항상 같지가 않음... ㅅㅂ
                }
            }()

            if (plusVisualValue3 == 0 || targetIndex == drCount - 1 || drCount == 1) { return }
            else {
                for i in (targetIndex+1)...(drCount-1) {
                    dailyRecords_savedAndVisible[i].visualValue3! += plusVisualValue3
                }
            }
        default:
            // 1 3 6 -> 1 (3) 4
            print("recalculate values")
            let minusVisualValue3: Int = {
                if targetIndex == 0 {
                    return dailyRecords_savedAndVisible[targetIndex].visualValue3!
                }
                else {
                    return dailyRecords_savedAndVisible[targetIndex].visualValue3! - dailyRecords_savedAndVisible[targetIndex-1].visualValue3!
                }
            }()
            
            if (minusVisualValue3 == 0 || targetIndex == drCount - 1 || drCount == 1) {} // NO!!!!
            else {
                for i in (targetIndex+1)...(drCount-1) {
                    dailyRecords_savedAndVisible[i].visualValue3! -= minusVisualValue3
                }
            }


            
        }

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
    
    static func getIntegratedDailyRecordColor(index:Int, colorScheme:ColorScheme) -> Color {
        return Self.getDailyRecordColor(index: index).adjust(brightness: colorScheme == .light ? -0.02 : -0.25).colorExpressionIntegration()
    }
    
    
    
    
}
