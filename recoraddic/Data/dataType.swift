//
//  dataType.swift
//  recoraddic
//
//  Created by 김지호 on 11/27/23.
//

import Foundation

func dataTypeFrom(_ input: Int) -> DataType {
    if input == 0 { return DataType.hour}
    else if input == 1 { return DataType.ox}
    else if input == 2 { return DataType.custom}
    else { return DataType.hour}
}

enum DataType:Int, CaseIterable, Identifiable {
    
    // 상용단위 도 추가
//    static let NO = -1 // ~~하지 않기 -> 이후 출시
//    static let NONE = 0
    case hour = 0
    case ox = 1
    case custom = 2

    var id: Int { self.rawValue }
    
//    static let typeNotation_kor:[DataType:String] = [.hour:"시간",.tomorrow:"OX (달성 유무 확인)",.dayAfterTomorrow:"사용자 지정"]
    
    static func eng_stringOf(dataType: DataType) -> String {
//        if dataType == DataType.NONE {
//            return "none"
//        }
        if dataType == .hour {
            return "hour"
        }
        else if dataType == .ox {
            return "ox"
        }
        else if dataType == .custom {
            return "custom"
        }
        else {
            return "ERROR"
        }
    }
    
    static func kor_stringOf(dataType: DataType) -> String {
//        if dataType == DataType.NONE {
//            return "없음"
//        }
        if dataType == .hour {
            return "시간"
        }
        else if dataType == .ox {
            return "OX (달성 유무 확인)"
        }

        else if dataType == .custom {
            return "사용자 지정"
        }
        else {
            return "ERROR"
        }
    }
    

    static func unitNotationOf(dataType: DataType, customDataTypeNotation: String? = nil) -> String {
        
        
//        if dataType == DataType.NONE
//        { return "" }
        
        // set to get O / X later
        if dataType == .hour
        { return "시간" }
        else if dataType == .ox {
            return "회"
        }
        else if dataType == .custom
        { return customDataTypeNotation ?? "no notation" }
        else
        { return "ERROR" }
        
        
    }
    
    
    static func maximumUnitOf(dataType:DataType) -> Int {
//        if dataType == DataType.NONE
//        { return 1000000 }
//        
        // set to get O / X later
        if dataType == .ox {
            return 1
        }
        else if dataType == .hour
        { return 720 }
        
        
        // set to get custom notation later
        else if dataType == .custom
        { return 100000000 }
        
        else
        { return -999999999 }
    }
    
    static func secondaryMaximumUnitOf(dataType:DataType) -> Int { // used for data exceeding goal, the goal set by the maximumUnit
        let primaryMaxiumUnitValue = self.maximumUnitOf(dataType: dataType)
        
        // set to get O / X later
        if dataType == .ox {
            return primaryMaxiumUnitValue
        }
        
        else if dataType == .hour
        { return primaryMaxiumUnitValue*4/3 } // -> 24hour

        
        else {
            return primaryMaxiumUnitValue*2
        }
    }
    
        
    
    static func string_unitDataToRepresentableData_hours(data: Int) -> (String, String) {
        return (String(format: "%d", data/60) , String(format: "%d", data%60))
    }
    
    static func string_fullRepresentableNotation(data: Int, dataType: DataType, customDataTypeNotation: String? = nil) -> String {
        if dataType == .ox {
            return "\(data)"
        }
        if dataType == .hour {
            let (hours,minutes) = string_unitDataToRepresentableData_hours(data: data)
            if hours == "0" {
                return "\(minutes)min"
            }
            else if hours != "0" && minutes == "0" {
                return "\(hours)hr"

            }
            else {
                return "\(hours)h \(minutes)m"
            }
        }
        if dataType == .custom {
            return "\(data) \(customDataTypeNotation ?? "notationError")"
        }
        else {
            return "error: string_fullRepresentableNotation"
        }
        

    }
    
    static func cumulative_integratedValueNotation(data:Int, dataType:DataType) -> Int {
        if dataType == .hour {
            return data/60
        }
        else {
            return data
        }
    }
    
    
//    static func float_unitDataToRepresentableData(data: Int, dataType: Int) -> CGFloat {
//        
//        if data < 0 || dataType > .custom || dataType < .ox
//        { return 99999 }
//        
//        
////        if dataType == DataType.NONE
////        { return CGFloat(data) }
//        
//        else if dataType == .ox {
//            if data != 0 && data != 1 { return 99999 }
//            else { return CGFloat(data) }
//        }
//        
//        else if dataType == DataType.REP
//        { return CGFloat(data) }
//     
//        // (unit of HOUR) == 0.1 hour(6 min)
//        else if dataType == .hour
//        { return CGFloat(Double(data)*0.1) }
//        
//
//        
//        else if dataType == .custom
//        { return CGFloat(data) }
//        
//        else
//        { return 99999 }
//        
//        
//    }
    
}
