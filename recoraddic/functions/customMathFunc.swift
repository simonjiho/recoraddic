//
//  customMathFunc.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/07/23.
//

import Foundation


func windingNumberAlgorithm(coordinates: CGPoint, polygon: [CGPoint]) -> Bool {
    let n = polygon.count
    var wn = 0
    for i in 0..<n {
        let p1 = polygon[i]
        let p2 = polygon[(i + 1) % n]
        if p1.y <= coordinates.y {
            if p2.y > coordinates.y {
                if isLeft(p1, p2, coordinates) > 0 {
                    wn += 1
                }
            }
        } else {
            if p2.y <= coordinates.y {
                if isLeft(p1, p2, coordinates) < 0 {
                    wn -= 1
                }
            }
        }
    }
    
    if wn == 0 { return false }
    else { return true }
    
}

func isLeft(_ p1: CGPoint, _ p2: CGPoint, _ point: CGPoint) -> CGFloat {
    return (p2.x - p1.x) * (point.y - p1.y) - (point.x - p1.x) * (p2.y - p1.y)
}


func twoNumberToHour(hour:Int,min6:Int) -> Int{
    
    return hour*12 + min6
} // 0.1시간 == 6분 == 1


func minimumBoundary(of data: Int, byMultiplying blockValue: Int) -> CGFloat {
    var returnVal:Int = blockValue
    while returnVal <  data {
        returnVal += blockValue
    }
    
    return CGFloat(returnVal)
}

func divideBy60(_ value: Int) -> (Int, Int) {
    let a: Int = value / 60
    let b: Int = value % 60
    return (a, b)
}
