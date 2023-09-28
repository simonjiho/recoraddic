//
//  shelf.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/28.
//

import Foundation
import SwiftUI


// 기본: 책장 / 미술관 / 일기장..?
// 얘도 다양한 형태로 저장소 스킨 바꿀 수 있음 (정말 다양하게!)





struct MainView_Shelf: View {
    
    var records: [Record]

//    var currentRecordModel = recordModel_Basic<recordName_Basic>()
//    var figures: RecordModelFig = currentRecordModel.figures
//    var positions: RecordModelPos = currentRecordModel.positions
//    // chosen by currentRecordData.adjustedModel later on
//
//
//    var items: [Group]
//


    var body: some View {
//        ShelfView(records: $records)
        
        Text("shelf!")
    }
    
}


//
//struct ShelfView: View {
//
//    @Binding var records: SampleRecords
//
//    var model: String
//    var data: Record
//
//    init() {
//        self.data = records.records[0]
//        self.model = data.adjustedModel
//    }
//
//    var body: some View {
//        if model == "default" {
//            RecordModel_default(data)
//        }
//    }
//
//}
