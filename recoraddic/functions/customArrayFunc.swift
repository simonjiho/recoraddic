//
//  customArrayFunc.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/12.
//

import Foundation


func countNonzeroFromEnd(_ input: Array<Float>) -> Int {
    
    var count = 0
    for element in input.reversed() {
        if element != 0 {
            count += 1
        } else {
            break
        }
    }
    
    return count
}


func sumFloatArray(_ input: Array<Float>) -> Float {
    let sum = input.reduce(0, +)
    return sum
}
