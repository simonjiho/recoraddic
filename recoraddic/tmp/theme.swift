//
//  theme.swift
//  recoraddic
//
//  Created by 김지호 on 11/15/23.
//

import Foundation
import SwiftUI



//let themeSets: [String:ThemeSet] = ["default1":recoraddic.default1]
// add debugging to check the key value and Theme.name is the same




// 나중에 facial expression과 slider thumb 도 넣기, sliderbar도 넣기
// cell과 stone에 이름 나중에 붙여주기


class ThemeSet {
    var name: String
    var stones:[Int:Image] = [:] //ImageInsets
    var shapes:[Int:[CGPoint]] = [:] //how to clip ImageInsets
    var thumbs:[Int:Image] = [:] // ruleFor thumbs image:
//    var purposeColorInsets:[String:Color] = [:]
    var questBackground: Image
    
    var sliderBarColor: Color
    var sliderThumbColor: Color
    
    init(name:String, questBackground:Image, sliderBarColor:Color, sliderThumbColor:Color) {
        self.name = name
        self.questBackground = questBackground
        self.sliderBarColor = sliderBarColor
        self.sliderThumbColor = sliderThumbColor
    }
}



// modifier로 할 것들: action, 크기, 후광효과
// 직접 구성할 것들: shape, image


struct ActionVariableInsets {
    var rotationPoints: [TimeCurvePoint]
    var xOffsetPoints: [TimeCurvePoint]// x: 시간, y:값
    var yOffsetPoints: [TimeCurvePoint]
    var scalePoints: [TimeCurvePoint]
    var xStretchePoints: [TimeCurvePoint]
    var yStretchePoints: [TimeCurvePoint]
    var opacityPoints: [TimeCurvePoint]
}

// This should be geometry-relative
struct TimeCurvePoint {
    var curveStyle: String
    var value: CGFloat
    var duration: CGFloat
    
    init(_ curveStyle: String, value: CGFloat, duration: CGFloat) {
        self.curveStyle = curveStyle
        self.value = value
        self.duration = duration

    }

}


struct VertexForShape {
    
    enum DrawingOption {
        case line
        case curve1
        case curve2
        
    }
    
    var points: [CGPoint]
    var drawingOptioss: [DrawingOption]
}

