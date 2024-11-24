//
//  notationFunc.swift
//  recoraddic
//
//  Created by 김지호 on 2/5/25.
//



typealias Minutes = Int
extension Minutes {
    
    var hhmmFormat: String {
        
        let (hours,minutes): (String, String) = (String(format: "%d", self/60) , String(format: "%d", self%60))
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
}







