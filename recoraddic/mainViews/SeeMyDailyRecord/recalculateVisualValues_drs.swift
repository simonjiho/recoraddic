//
//  recalculateVisualValues.swift
//  recoraddic
//
//  Created by 김지호 on 3/3/24.
//

import Foundation
extension MainView_SeeMyDailyRecord {
    func recalculateVisualValues_themeChanged() -> Void {
        if selectedDailyRecordSet.dailyRecordThemeName == "stoneTower_0" {
            
        }
        if selectedDailyRecordSet.dailyRecordThemeName == "stoneTower_1" {
            
        }
        else {
            
        }
    }
//    func recalculateVisualValues_hiddenOrDeleted(isHidden:Bool = false, isDeleted:Bool = false) -> Void {
//        if selectedDailyRecordSet.dailyRecordThemeName == "stoneTower_1" {
//            print("recalculate values")
//            let dailyRecords_saved: [DailyRecord] = selectedDailyRecordSet.dailyRecords!.sorted(by: {dr1, dr2 in dr1.date < dr2.date}).filter({$0.visualValue1 != nil})
//            
//            let targetIndex: Int = dailyRecords_saved.firstIndex(of: selectedRecord!)!
//            
//            let minusVisualValue3: Int = {
//                if targetIndex == 0 {
//                    return dailyRecords_saved[targetIndex].visualValue3!
//                }s
//                else {
//                    return dailyRecords_saved[targetIndex].visualValue3! - dailyRecords_saved[targetIndex-1].visualValue3!
//                }
//            }()
//            let drCount: Int = dailyRecords_saved.count
//            
//            if (minusVisualValue3 == 0 || targetIndex == drCount - 1 || drCount == 1) {} // NO!!!!
//            else {
//                for i in (targetIndex+1)...(drCount-1) {
//                    dailyRecords_saved[i].visualValue3! -= minusVisualValue3
//                }
//            }
//            if isHidden {
////                let hiddenRecord: DailyRecord = selectedRecord!
//                selectedRecord = nil
////                hiddenRecord.hide = true // 윗줄과 순서 바꾸면 오류 날수도
//            }
//            if isDeleted {
//                let deletedRecord: DailyRecord = selectedRecord!
//                selectedRecord = nil
//                modelContext.delete(deletedRecord) // 윗줄과 순서 바꾸면 오류 날수도
//            }
//        }
//        else {
//            print("no matched themeName..")
//        }
//    }
}



