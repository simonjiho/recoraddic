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
        return tierColor.adjust(brightness: -0.4)
    case 2:
        return tierColor.adjust(brightness: -0.35)
    case 3:
        return tierColor.adjust(brightness: -0.45)
    case 4:
        return tierColor.adjust(brightness: -0.5)
    case 5:
        return tierColor.adjust(saturation:0.2
                                ,brightness: -0.45)
    case 6:
        return tierColor.adjust(brightness: -0.5)
    case 7:
//        return tierColor.adjust(brightness: -0.2)
//        return tierColor.adjust(brightness: 0.1)
//        return Color.purple.adjust(brightness: 0.8)
        return tierColor.adjust(brightness: -0.45)


    case 8:
        return tierColor.adjust(brightness: -0.45)

    default:
        return tierColor.adjust(brightness: -0.5)
    }
}

func getDarkTierColorOf2(tier:Int) -> Color {
    
    let tierColor: Color = getTierColorOf(tier: tier)
    
    switch tier/5 {
    case 0:
        return tierColor.adjust(brightness: -0.1)
    case 1:
        return tierColor.adjust(brightness: -0.15)
    case 2:
        return tierColor.adjust(brightness: -0.1)
    case 3:
        return tierColor.adjust(brightness: -0.2)
    case 4:
        return tierColor.adjust(brightness: -0.2)
    case 5:
        return tierColor.adjust(saturation:0.2
                                ,brightness: -0.15)
    case 6:
        return tierColor.adjust(brightness: -0.2)
    case 7:
//        return tierColor.adjust(brightness: -0.2)
//        return tierColor.adjust(brightness: 0.1)
//        return Color.purple.adjust(brightness: 0.8)
        return tierColor.adjust(brightness: -0.2)


    case 8:
        return tierColor.adjust(brightness: -0.2)

    default:
        return tierColor.adjust(brightness: -0.25)
    }
}
func getDarkTierColorOf3(tier:Int) -> Color {
    
    let tierColor: Color = getTierColorOf(tier: tier)
    
    switch tier/5 {
    case 0:
        return tierColor.adjust(brightness: -0.15)
    case 1:
        return tierColor.adjust(brightness: -0.25)
    case 2:
        return tierColor.adjust(brightness: -0.2)
    case 3:
        return tierColor.adjust(brightness: -0.3)
    case 4:
        return tierColor.adjust(brightness: -0.35)
    case 5:
        return tierColor.adjust(saturation:0.2
                                ,brightness: -0.3)
    case 6:
        return tierColor.adjust(brightness: -0.35)
    case 7:
//        return tierColor.adjust(brightness: -0.2)
//        return tierColor.adjust(brightness: 0.1)
//        return Color.purple.adjust(brightness: 0.8)
        return tierColor.adjust(brightness: -0.3)


    case 8:
        return tierColor.adjust(brightness: -0.35)

    default:
        return tierColor.adjust(brightness: -0.4)
    }

}


func getBrightTierColorOf(tier:Int) -> Color { // questCheckBox(bright)
    
    let tierColor: Color = getTierColorOf(tier: tier)
    
    switch tier/5 {
    case 0...2:
        return tierColor.adjust(brightness: 0.15)
    case 3:
        return tierColor.adjust(brightness: 0.20)
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
        return tierColor.adjust(brightness: 0.05)
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


func getGradientColorsOf(tier:Int, type:Int = 0, isDark:Bool = false) -> [Color] { // quest checkbox
    

    let tierColor_dark = getDarkTierColorOf(tier: tier).colorExpressionIntegration()
    let tierColor_dark2 = getDarkTierColorOf2(tier: tier).colorExpressionIntegration()
    let tierColor_dark3 = getDarkTierColorOf3(tier: tier).colorExpressionIntegration()
    let tierColor:Color = getTierColorOf(tier: tier).colorExpressionIntegration()
    let tierColor_bright:Color = getBrightTierColorOf(tier: tier).colorExpressionIntegration()
    let tierColor_bright2:Color = getBrightTierColorOf2(tier: tier).colorExpressionIntegration()
    let tierColor_bright3:Color = getBrightTierColorOf3(tier: tier).colorExpressionIntegration()

    if !isDark {
        if type == 0 { //questCheckbox
            return [tierColor_bright3,tierColor_bright3, tierColor_bright, tierColor_bright3, tierColor_bright3]
        }
        else if type == 1 { //questThumbnail
            return [tierColor, tierColor_bright2, tierColor]
        }
        else if type == 2 { // 달력
            return [tierColor_bright2, tierColor]
        }
        else if type == 3 {
            return [tierColor, tierColor_bright2, tierColor, tierColor_bright2, tierColor]
        }
        else {
            return [tierColor, tierColor_bright, tierColor]
        }
    } else {
        if type == 0 { //questCheckbox
//            return [tierColor,tierColor, tierColor_bright3, tierColor, tierColor]
            return [tierColor_dark2,tierColor_dark2, tierColor_dark2, tierColor_dark2, tierColor_dark2]
        }
        else if type == 1 { //questThumbnail
            return [tierColor_bright2,tierColor, tierColor_bright2]
        }
        else if type == 2 { // 달력
            return [tierColor_bright2, tierColor]
        }
        else if type == 3 {
            return [tierColor_bright2, tierColor, tierColor_bright2, tierColor, tierColor_bright2]
        }
        else {
            return [tierColor_bright, tierColor, tierColor_bright]
        }
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



#Preview(body: {
    
    HStack {
        VStack {
            getDarkTierColorOf(tier: 0)
            getDarkTierColorOf(tier: 5)
            getDarkTierColorOf(tier: 10)
            getDarkTierColorOf(tier: 15)
            getDarkTierColorOf(tier: 20)
            getDarkTierColorOf(tier: 25)
            getDarkTierColorOf(tier: 30)
            getDarkTierColorOf(tier: 35)
            getDarkTierColorOf(tier: 40)
        } // dark
        VStack {
            getDarkTierColorOf3(tier: 0)
            getDarkTierColorOf3(tier: 5)
            getDarkTierColorOf3(tier: 10)
            getDarkTierColorOf3(tier: 15)
            getDarkTierColorOf3(tier: 20)
            getDarkTierColorOf3(tier: 25)
            getDarkTierColorOf3(tier: 30)
            getDarkTierColorOf3(tier: 35)
            getDarkTierColorOf3(tier: 40)
        } // dark3
        VStack {
            getDarkTierColorOf2(tier: 0)
            getDarkTierColorOf2(tier: 5)
            getDarkTierColorOf2(tier: 10)
            getDarkTierColorOf2(tier: 15)
            getDarkTierColorOf2(tier: 20)
            getDarkTierColorOf2(tier: 25)
            getDarkTierColorOf2(tier: 30)
            getDarkTierColorOf2(tier: 35)
            getDarkTierColorOf2(tier: 40)
        } // dark2
        VStack {
            getTierColorOf(tier: 0)
            getTierColorOf(tier: 5)
            getTierColorOf(tier: 10)
            getTierColorOf(tier: 15)
            getTierColorOf(tier: 20)
            getTierColorOf(tier: 25)
            getTierColorOf(tier: 30)
            getTierColorOf(tier: 35)
            getTierColorOf(tier: 40)
        } // original
        VStack {
            getBrightTierColorOf3(tier: 0)
            getBrightTierColorOf3(tier: 5)
            getBrightTierColorOf3(tier: 10)
            getBrightTierColorOf3(tier: 15)
            getBrightTierColorOf3(tier: 20)
            getBrightTierColorOf3(tier: 25)
            getBrightTierColorOf3(tier: 30)
            getBrightTierColorOf3(tier: 35)
            getBrightTierColorOf3(tier: 40)
        } // bright3
        VStack {
            getBrightTierColorOf(tier: 0)
            getBrightTierColorOf(tier: 5)
            getBrightTierColorOf(tier: 10)
            getBrightTierColorOf(tier: 15)
            getBrightTierColorOf(tier: 20)
            getBrightTierColorOf(tier: 25)
            getBrightTierColorOf(tier: 30)
            getBrightTierColorOf(tier: 35)
            getBrightTierColorOf(tier: 40)
        } // bright
        VStack {
            getBrightTierColorOf2(tier: 0)
            getBrightTierColorOf2(tier: 5)
            getBrightTierColorOf2(tier: 10)
            getBrightTierColorOf2(tier: 15)
            getBrightTierColorOf2(tier: 20)
            getBrightTierColorOf2(tier: 25)
            getBrightTierColorOf2(tier: 30)
            getBrightTierColorOf2(tier: 35)
            getBrightTierColorOf2(tier: 40)
        } // bright2
    }
})



struct InvertColorInLightMode: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .light {
            content.colorInvert()
        } else {
            content
        }
    }
}

extension View {
    func invertColorInLightMode() -> some View {
        self.modifier(InvertColorInLightMode())
    }
}
