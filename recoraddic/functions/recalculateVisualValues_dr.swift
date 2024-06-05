//
//  recalculateVisualValues.swift
//  recoraddic
//
//  Created by 김지호 on 3/15/24.
//

import Foundation
//import SwiftUI // not necessary.
//import SwiftData // not necessary.


enum DrEditOption {
    case hide
    case trashCan
    case delete
    case visible
}


// MARK: use this function, then adjust the changes(isHidden, inTrashCan)
func adjustDailyRecordChanges(dailyRecord:DailyRecord, option:DrEditOption) -> Void {
    
    
    if option == .visible { // invisible to visible
        dailyRecord.isHidden = false
        dailyRecord.inTrashCan = false
    }
    
    
    let invisbToInvisb: Bool = (option == .delete || option == .trashCan) && !dailyRecord.isVisible()
    // case that no needs of recalculation: isHidden -> intrashCan, inTrashCan -> delete
    let drs: DailyRecordSet = dailyRecord.dailyRecordSet!
    let isConstantTheme: Bool = dailyRecordThemeNames_withoutQuestions.contains(drs.dailyRecordThemeName)
    
    if !(invisbToInvisb || isConstantTheme) {
        recalculateVisualValues(dailyRecord: dailyRecord, drs:drs, option: option)
    }
    
    
    if option == .hide {
        dailyRecord.isHidden = true
    }
    else if option == .trashCan {
        dailyRecord.inTrashCan = true
        dailyRecord.isHidden = false
    }
    
    // for deletion, it will be executed inside the view.


}


func recalculateVisualValues(dailyRecord:DailyRecord, drs:DailyRecordSet, option:DrEditOption) -> Void {
    
    let dailyRecords: [DailyRecord] = drs.dailyRecords!
    let dailyRecords_savedAndVisible: [DailyRecord] = dailyRecords.filter({$0.date != nil && $0.isVisible()}).sorted(by: {dr1, dr2 in dr1.date! < dr2.date!})
    let targetIndex: Int = dailyRecords_savedAndVisible.firstIndex(of: dailyRecord)!
    let drCount: Int = dailyRecords_savedAndVisible.count
    
    
    switch drs.dailyRecordThemeName {

    case "stoneTower_1":
        StoneTower_1.recalculateVisualValues(
            dailyRecord: dailyRecord,
            dailyRecords_savedAndVisible: dailyRecords_savedAndVisible,
            targetIndex: targetIndex,
            drCount: drCount,
            option: option
        )
        
    default:
        print("no matched themeName..")
    
    }
}

