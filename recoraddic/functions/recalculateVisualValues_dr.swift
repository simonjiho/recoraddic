//
//  recalculateVisualValues.swift
//  recoraddic
//
//  Created by 김지호 on 3/15/24.
//

import Foundation
//import SwiftUI // not necessary.
//import SwiftData // not necessary.



//func recalculateVisualValues_hiddenOrDeleted(dailyRecord:DailyRecord, isHidden:Bool = false, isDeleted:Bool = false) -> DailyRecord? {
func recalculateVisualValues_hiddenOrDeleted(dailyRecord:DailyRecord) -> Void {
    
    let dailyRecordSet: DailyRecordSet = dailyRecord.dailyRecordSet!
    let dailyRecords: [DailyRecord] = dailyRecordSet.dailyRecords!
    let dailyRecords_savedAndUnhidden: [DailyRecord] = dailyRecords.filter({$0.date != nil && !$0.hide}).sorted(by: {dr1, dr2 in dr1.date! < dr2.date!})
    let targetIndex: Int = dailyRecords_savedAndUnhidden.firstIndex(of: dailyRecord)!
    let drCount: Int = dailyRecords_savedAndUnhidden.count
    
    
    
    switch dailyRecordSet.dailyRecordThemeName {
     
        
        
    case "stoneTower_0":
        return
    case "stoneTower_1":
        // 1 3 6 -> 1 (3) 4
        print("recalculate values")
        let minusVisualValue3: Int = {
            if targetIndex == 0 {
                return dailyRecords_savedAndUnhidden[targetIndex].visualValue3!
            }
            else {
                return dailyRecords_savedAndUnhidden[targetIndex].visualValue3! - dailyRecords_savedAndUnhidden[targetIndex-1].visualValue3!
            }
        }()
        
        if (minusVisualValue3 == 0 || targetIndex == drCount - 1 || drCount == 1) {} // NO!!!!
        else {
            for i in (targetIndex+1)...(drCount-1) {
                dailyRecords_savedAndUnhidden[i].visualValue3! -= minusVisualValue3
            }
        }
        
        
    default:
        print("no matched themeName..")
    
    }

    
    
//    if isDeleted {
//        return dailyRecord
//    }
//    else { // is hidden
//        return nil
//    }
//    
}


func recalculateVisualValues_unhidden(dailyRecord:DailyRecord) -> Void {
    
    let dailyRecordSet: DailyRecordSet = dailyRecord.dailyRecordSet!
    let dailyRecords: [DailyRecord] = dailyRecordSet.dailyRecords!
    let dailyRecords_savedAndUnhidden: [DailyRecord] = dailyRecords.filter({$0.date != nil && !$0.hide}).sorted(by: {dr1, dr2 in dr1.date! < dr2.date!})
    let targetIndex: Int = dailyRecords_savedAndUnhidden.firstIndex(of: dailyRecord)!
    let drCount: Int = dailyRecords_savedAndUnhidden.count
    
    
    switch dailyRecordSet.dailyRecordThemeName {
    case "stoneTower_0":
        return
    case "stoneTower_1":
        // 1 3 6 -> 1 4 -> 1 3 6
        // 1 3 6 10 -> 1 (3) 4 7 -> 1 (3)
        let prevPos:Int = targetIndex == 0 ? 0 : dailyRecords_savedAndUnhidden[targetIndex-1].visualValue3!
        let newVisualVal3:Int = StoneTower_1.calculateVisualValue3(qVal1: dailyRecord.questionValue1, qVal2: dailyRecord.questionValue2, qVal3: dailyRecord.questionValue3, prevPos)
        dailyRecord.visualValue3 = newVisualVal3
//        let nextPos:Int = targetIndex == dailyRecords_savedAndUnhidden.count - 1 ? dailyRecords_savedAndUnhidden[targetIndex+1].visualValue3! : 0
//        let nextPox_Gap: Int =

        let plusVisualValue3: Int = {
            if targetIndex == 0 {
                return newVisualVal3
            }
            else {
                return newVisualVal3 - dailyRecords_savedAndUnhidden[targetIndex-1].visualValue3! // 음 어떻게 할까 이게 항상 같지가 않음... ㅅㅂ
            }
        }()

        if (plusVisualValue3 == 0 || targetIndex == drCount - 1 || drCount == 1) { return }
        else {
            for i in (targetIndex+1)...(drCount-1) {
                dailyRecords_savedAndUnhidden[i].visualValue3! += plusVisualValue3
            }
        }
        
    default:
        print("no matched themeName..")
    
    
    }


    

}
