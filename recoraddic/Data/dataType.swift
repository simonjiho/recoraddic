//
//  dataType.swift
//  recoraddic
//
//  Created by 김지호 on 11/27/23.
//

import Foundation

final class DataType {
    
    // 상용단위 도 추가
//    static let NO = -1 // ~~하지 않기 -> 이후 출시
//    static let NONE = 0
    static let OX = 1
    static let REP = 2 // 최대 100000회
//    static let SEC = 3 // 최대 2시간 -> 7200초
//    static let MIN = 4 // 최대 6시간 -> 360분
    static let HOUR = 5 // 최대 18시간 -> 180*6min
//    static let MONEY = 6 // 최대 100억 -> 1억*100원
    static let CUSTOM = 7 // 최대
    
    init() {
    }
    
    static func eng_stringOf(dataType: Int) -> String {
//        if dataType == DataType.NONE {
//            return "none"
//        }
        if dataType == DataType.OX {
            return "ox"
        }
        else if dataType == DataType.REP {
            return "rep"
        }
        else if dataType == DataType.HOUR {
            return "hour"
        }
        else if dataType == DataType.CUSTOM {
            return "custom"
        }
        else {
            return "ERROR"
        }
    }
    
    static func kor_stringOf(dataType: Int) -> String {
//        if dataType == DataType.NONE {
//            return "없음"
//        }
        if dataType == DataType.OX {
            return "OX (달성 유무 확인)"
        }
        else if dataType == DataType.REP {
            return "횟수"
        }
        else if dataType == DataType.HOUR {
            return "시간"
        }
        else if dataType == DataType.CUSTOM {
            return "사용자 지정"
        }
        else {
            return "ERROR"
        }
    }
    
//    static func dataTypeOf(string: String) -> Int {
////        if string == "none" {
////            return DataType.NONE
////        }
//        if string == "ox" {
//            return DataType.OX
//        }
//        else if string == "rep" {
//            return DataType.REP
//        }
//        else if string == "sec" {
//            return DataType.SEC
//        }
//        else if string == "min" {
//            return DataType.MIN
//        }
//        else if string == "hour" {
//            return DataType.HOUR
//        }
//        else if string == "custom" {
//            return DataType.CUSTOM
//        }
//        else {
//            return -99999
//        }
//
//        
//    }
    
    static func unitNotationOf(dataType: Int, customDataTypeNotation: String? = nil) -> String {
        
        if dataType > DataType.CUSTOM || dataType < DataType.OX
        { return "ERROR" }
        
        
//        if dataType == DataType.NONE
//        { return "" }
        
        // set to get O / X later
        else if dataType == DataType.OX {
            return "회"
        }
        
        else if dataType == DataType.REP
        { return "회" }
        
     
        else if dataType == DataType.HOUR
        { return "시간" }
        

        
        
        // set to get custom notation later
        else if dataType == DataType.CUSTOM
        { return customDataTypeNotation! }
        
        else
        { return "ERROR" }
        
        
    }
    
    
    static func maximumUnitOf(dataType:Int) -> Int {
//        if dataType == DataType.NONE
//        { return 1000000 }
//        
        // set to get O / X later
        if dataType == DataType.OX {
            return 1
        }
        
        else if dataType == DataType.REP
        { return 100000 }
        
        
        else if dataType == DataType.HOUR
        { return 720 }
        
        
        // set to get custom notation later
        else if dataType == DataType.CUSTOM
        { return 100000000 }
        
        else
        { return -999999999 }
    }
    
    static func secondaryMaximumUnitOf(dataType:Int) -> Int { // used for data exceeding goal, the goal set by the maximumUnit
        let primaryMaxiumUnitValue = self.maximumUnitOf(dataType: dataType)
        
        // set to get O / X later
        if dataType == DataType.OX {
            return primaryMaxiumUnitValue
        }
        
        else if dataType == DataType.HOUR
        { return primaryMaxiumUnitValue*4/3 } // -> 24hour

        
        else {
            return primaryMaxiumUnitValue*2
        }
    }
    
        
//    static func string_unitDataToRepresentableData(data: Int, dataType: Int) -> String {
//        
//        if data < 0 || dataType > DataType.CUSTOM || dataType < DataType.OX
//        { return String(format: "%g", 99999) }
//        
//        
////        if dataType == DataType.NONE
////        { return String(format: "%d", data) }
//        
//        else if dataType == DataType.OX {
//            if data != 0 && data != 1 { return String(format: "%d", 99999) }
//            else { return String(format: "%d", data) }
//        }
//        
//        else if dataType == DataType.REP
//        { return String(format: "%d", data) }
//     
//        //MARK: (unit of HOUR) == 0.1 hour(6 min)
//        else if dataType == DataType.HOUR
//        { return String(format: "%.1f", Double(data)*0.1) }
//        
//        
//        else if dataType == DataType.CUSTOM
//        { return String(format: "%d", data) }
//        
//        else
//        { return String(format: "%d", 99999) }
//        
//        
//    }
    
    static func string_unitDataToRepresentableData_hours(data: Int) -> (String, String) {
        return (String(format: "%d", data/60) , String(format: "%d", data%60))
    }
    
    static func string_fullRepresentableNotation(data: Int, dataType: Int, customDataTypeNotation: String? = nil) -> String {
        if dataType == DataType.OX {
            return "\(data)"
        }
        if dataType == DataType.REP {
            return "\(data) 회"
        }
        if dataType == DataType.HOUR {
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
        if dataType == DataType.CUSTOM {
            return "\(data) \(customDataTypeNotation ?? "notationError")"
        }
        else {
            return "error: string_fullRepresentableNotation"
        }
        

    }
    
    static func cumulative_integratedValueNotation(data:Int, dataType:Int) -> Int {
        if dataType == DataType.HOUR {
            return data/60
        }
        else {
            return data
        }
    }
    
    
//    static func float_unitDataToRepresentableData(data: Int, dataType: Int) -> CGFloat {
//        
//        if data < 0 || dataType > DataType.CUSTOM || dataType < DataType.OX
//        { return 99999 }
//        
//        
////        if dataType == DataType.NONE
////        { return CGFloat(data) }
//        
//        else if dataType == DataType.OX {
//            if data != 0 && data != 1 { return 99999 }
//            else { return CGFloat(data) }
//        }
//        
//        else if dataType == DataType.REP
//        { return CGFloat(data) }
//     
//        // (unit of HOUR) == 0.1 hour(6 min)
//        else if dataType == DataType.HOUR
//        { return CGFloat(Double(data)*0.1) }
//        
//
//        
//        else if dataType == DataType.CUSTOM
//        { return CGFloat(data) }
//        
//        else
//        { return 99999 }
//        
//        
//    }
    
}
