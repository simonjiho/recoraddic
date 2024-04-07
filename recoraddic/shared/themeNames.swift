//
//  themeNames.swift
//  recoraddic
//
//  Created by 김지호 on 1/27/24.
//

import Foundation


let dailyRecordThemeNames:[String] = ["stoneTower_0","stoneTower_1"]
let backgroundThemeNames:[String] = ["StoneTowerBackground_1"]


let dailyRecordThemeNames_withoutQuestions:[String] = ["stoneTower_0"]
let dailyRecordThemeNames_withQuestions:[String] = ["stoneTower_1"]


func doesThemeAskQuestions(_ name: String) -> Bool {
    if recoraddic.dailyRecordThemeNames_withoutQuestions.contains(name) { return false}
    else if recoraddic.dailyRecordThemeNames_withQuestions.contains(name) { return true}
    else { return false }

}
