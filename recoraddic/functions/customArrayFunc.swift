//
//  customArrayFunc.swift
//  recoraddic
//
//  Created by 김지호 on 2023/08/12.
//

import Foundation


func countNonzeroFromEnd(_ input: Array<Int>) -> Int {
    
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


func sumIntArray(_ input: Array<Int>) -> Int {
    if input.isEmpty { return 0 }
    else {
        let sum = input.reduce(0, +)
        return sum
    }
}


func sumDoubleArray(_ input: Array<Double>) -> Double {
    let sum = input.reduce(0, +)
    return sum
}
