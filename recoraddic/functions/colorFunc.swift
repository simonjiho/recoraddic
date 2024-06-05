//
//  adjustColor.swift
//  recoraddic
//
//  Created by 김지호 on 1/24/24.
//

import Foundation
import SwiftUI

extension Color { // hue: 색조 , saturation: 채도
    func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
        let uiColor = UIColor(self)
        var currentHue: CGFloat = 0
        var currentSaturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var currentOpacity: CGFloat = 0

        if uiColor.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrightness, alpha: &currentOpacity) {
            return Color(hue: currentHue + hue, saturation: currentSaturation + saturation, brightness: currentBrightness + brightness, opacity: currentOpacity + opacity)
        }
        print("oh....")
        return self
    }
    func getRGBA() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            r = r > 1.0 ? 1.0 : r
            g = g > 1.0 ? 1.0 : g
            b = b > 1.0 ? 1.0 : b
            return (r,g,b,a)
        }
        else {
            return (0,0,0,0)
        }
    }
    func colorExpressionIntegration() -> Color { //needed for color representation integration
        let rgba: (CGFloat,CGFloat,CGFloat,CGFloat) = self.getRGBA()
        return Color(red: rgba.0, green: rgba.1, blue: rgba.2)
    }

    
}

func getTierColorOf(tier:Int) -> Color {
    let iron = Color.black.adjust(brightness: 0.5)
    let bronze = Color.brown.adjust(brightness: 0.0)
    let silver = Color.gray.adjust(brightness:0.2) //
    let gold = Color.brown.adjust(brightness:0.37) //
//    let platinum = Color.blue.adjust(saturation:-0.5, brightness:0.4) //
    let platinum = Color(red:119.0/255.0 , green: 255.0/255.0, blue: 232.0/255.0) //119, 255, 232
//    let diamond = Color.cyan.adjust(saturation:-0.57, brightness:0.2)
    let diamond = Color(red:210.0/255.0 , green: 245.0/255.0, blue: 250.0/255.0) //rgb(210, 245, 250)
//    let master = Color(red: 0.3, green: 0.5, blue: 1.0).adjust(brightness:0.2)
    let master = Color(red:100.0/255.0 , green: 150.0/255.0, blue: 252.0/255.0) //100, 150, 252
    let superMaster = Color(red: 215.0/255.0, green: 189.0/255.0, blue: 238/255.0)
    let grandMaster = Color(red: 242.0/255.0, green: 140.0/255.0, blue: 136.0/255.0) //242, 152, 136
    
        
    switch tier/5 {
    case 0:
        return iron
    case 1:
        return bronze
    case 2:
        return silver
    case 3:
        return gold
    case 4:
        return platinum
    case 5:
        return diamond
    case 6:
        return master
    case 7:
        return superMaster
    case 8:
        return grandMaster
    default:
        return Color.black
    }
        
}

func getDarkTierColorOf(tier:Int) -> Color {
    
    let tierColor: Color = getTierColorOf(tier: tier)
    
    switch tier/5 {
    case 0:
        return tierColor.adjust(brightness: -0.3)
    case 1:
        return tierColor.adjust(brightness: -0.5)
    case 2:
        return tierColor.adjust(brightness: -0.35)
    case 3:
        return tierColor.adjust(brightness: -0.5)
    case 4:
        return tierColor.adjust(brightness: -0.5)
    case 5:
        return tierColor.adjust(brightness: -0.5)
    case 6:
        return tierColor.adjust(brightness: -0.5)
    case 7:
//        return tierColor.adjust(brightness: -0.2)
//        return tierColor.adjust(brightness: 0.1)
//        return Color.purple.adjust(brightness: 0.8)
        return tierColor.adjust(brightness: -0.5)


    case 8:
        return tierColor.adjust(brightness: -0.5)

    default:
        return tierColor.adjust(brightness: -0.5)
    }
}


func getBrightTierColorOf(tier:Int) -> Color { // questCheckBox(bright)
    
    let tierColor: Color = getTierColorOf(tier: tier)
    
    switch tier/5 {
    case 0...2:
        return tierColor.adjust(brightness: 0.15)
    case 3:
        return tierColor.adjust(brightness: 0.14)
    case 4:
        return tierColor.adjust(brightness: 0.17)
    case 5:
        return tierColor.adjust(brightness: 0.09)
    case 6:
        return tierColor.adjust(brightness: 0.5)
    case 7:
        return tierColor.adjust(brightness: 0.3)


    case 8:
        return tierColor.adjust(brightness: 0.45)

    default:
        return tierColor.adjust(brightness: 0.05)
    }
}


func getBrightTierColorOf2(tier:Int) -> Color { // questThumbnail
    
    let tierColor: Color = getTierColorOf(tier: tier)
    
    switch tier/5 {
    case 0...1:
        return tierColor.adjust(brightness: 0.3)
    case 2:
        return tierColor.adjust(brightness: 0.25)
    case 3:
        return tierColor.adjust(brightness: 0.25)
    case 4:
        return tierColor.adjust(brightness: 0.8)
    case 5:
        return tierColor.adjust(brightness: 0.15)
    case 6:
        return tierColor.adjust(brightness: 0.6)
    case 7:
        return tierColor.adjust(brightness: 0.35)
    case 8:
        return tierColor.adjust(brightness: 0.6)
    default:
        return tierColor.adjust(brightness: 0.1)
    }
}


func getBrightTierColorOf3(tier:Int) -> Color { // questCheckBox(dark)
    
    let tierColor: Color = getTierColorOf(tier: tier)
    
    switch tier/5 {
    case 0:
        return tierColor.adjust(brightness: 0.04)
    case 1:
        return tierColor.adjust(brightness: 0.02)
    case 2:
        return tierColor.adjust(brightness: 0.04)
    case 3:
        return tierColor.adjust(brightness: 0.1)
    case 4:
        return tierColor.adjust(brightness: 0.0)
    case 5:
        return tierColor.adjust(brightness: 0.0)
    case 6:
        return tierColor.adjust(brightness: 0.1)
    case 7:
        return tierColor.adjust(brightness: 0.15)
    case 8:
        return tierColor.adjust(brightness: 0.1)
    default:
        return tierColor.adjust(brightness: 0.0)
    }
}


func getGradientColorsOf(tier:Int, type:Int = 0) -> [Color] { // quest checkbox
    

    let tierColor:Color = getTierColorOf(tier: tier)
    let tierColor_bright:Color = getBrightTierColorOf(tier: tier)
    let tierColor_bright2:Color = getBrightTierColorOf2(tier: tier)
    let tierColor_bright3:Color = getBrightTierColorOf3(tier: tier)

    
    if type == 0 { //questCheckbox
        return [tierColor_bright3,tierColor_bright3, tierColor_bright, tierColor_bright3, tierColor_bright3]
    }
    else if type == 1 { //questThumbnail
        return [tierColor, tierColor_bright2, tierColor]
    }
    else if type == 2 {
        return [tierColor, tierColor_bright, tierColor, tierColor_bright, tierColor]
    }
    else if type == 3 {
        return [tierColor, tierColor_bright2, tierColor, tierColor_bright2, tierColor]
    }
    else {
        return [tierColor, tierColor_bright, tierColor]
    }
    
}


func getShadowColor(_ colorScheme:ColorScheme) -> Color {
    return colorScheme == .light ? .black.adjust(brightness:0.2) : .white.adjust(brightness:-0.2)

}

func getColorSchemeColor(_ colorScheme:ColorScheme) -> Color {
    return colorScheme == .light ? .white : .black
}

func getReversedColorSchemeColor(_ colorScheme:ColorScheme) -> Color {
    return colorScheme == .light ? .black : .white
}


