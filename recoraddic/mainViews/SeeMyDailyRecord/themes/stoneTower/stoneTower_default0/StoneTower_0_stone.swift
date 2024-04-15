//
//  StoneTower1_stones.swift
//  recoraddic
//
//  Created by 김지호 on 3/26/24.
//

// MARK: Path rules: start from top left, clockwise

import Foundation
import SwiftUI

struct StoneTower_0_stone: View {
    
    @Environment(\.colorScheme) var colorScheme

    var facialExpressionNum: Int
    
    var defaultColor:Color

    
    init(defaultColorIndex: Int, facialExpressionNum: Int) {
        self.facialExpressionNum = facialExpressionNum
        self.defaultColor = StoneTower_1.getDailyRecordColor(index: defaultColorIndex)
    }


    
    var body: some View {

        let stoneColor: Color = defaultColor.adjust(brightness: colorScheme == .light ? -0.27 : -0.64)
          
        
        GeometryReader { geometry in
            
            
//            let geoWidth = geometry.size.width
//            let geoHeight = geometry.size.height

            
            ZStack {
                // TODO: 그림자를 그 다음 stone과의 visualValue3 차이만큼 받아서 적용, nil이면 그림자 없음


                StoneShape(mainColor: stoneColor)
                    .opacity(0.85)
                
                if facialExpressionNum != 0 {

                    /*toneColor.adjust(brightness: -0.15)*/
                    Color.black
                        .mask {
                            Image("facialExpression_\(facialExpressionNum)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
        //                        .frame(height: geometry.size.height*0.8)
                                .frame(height: geometry.size.height*0.6)
                        }
                        .opacity(0.3)




                }
                
            }   // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }

    }
        
        
}



struct StoneShape: View {
    
    @Environment(\.colorScheme) var colorScheme

    var mainColor: Color
    
    var body: some View {
        
        let mainColorDarkness: CGFloat = {
            let mainColor_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = mainColor.getRGBA()

            return 3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2
        }()

        
        let color1 = {
            if mainColorDarkness > 0.2 {
                return mainColor.adjust(saturation:-0.06, brightness: colorScheme == .light ? 0.08 : 0.07)
            }
            else {

                return mainColor.adjust(saturation:-0.045, brightness: colorScheme == .light ? 0.08 : 0.07)

            }
        }()

        let color3 = {
            if mainColorDarkness > 0.1 || colorScheme == .dark {
                return mainColor
            }
            else {
//                return mainColor.adjust(saturation:-0.04, brightness: 0.03)
//                print("hoho")
                return mainColor.adjust(brightness: -0.03)

            }
        }()

        
//        let color4 = mainColor.adjust(brightness: colorScheme == .light ? -0.03 : -0.05)
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.1 : -0.13)

        
        // MARK: Canvas does not apply color in the same process as the normal SwiftUI views. Even it's the same Color object(by SwiftUI), the display will return the unusual different color. So it should be substracted as rgb component to apply the same color. (24.03.29)
        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        
        

        Canvas { context, size in
            let frameWidth = size.width*0.85
            let frameHeight = size.height
            context.blendMode = .lighten
            context.opacity = 1.0
            let xOrigin: CGFloat = size.width*0.075

//            let gradient:LinearGradient = LinearGradient(colors: [color1,color2,color3,color4,color5], startPoint: .top, endPoint: .bottom)
//            let gradient:Gradient = Gradient(colors: [color1,color2,color3,color3,color3,color3,color3,color4,color5])
            
//            let outLine:Path = Path(roundedRect: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight), cornerRadius: frameWidth*0.1, style: .circular)
            let outLine:Path = Path(roundedRect: CGRect(x: xOrigin, y: 0, width: frameWidth, height: frameHeight), cornerSize:CGSize(width: frameWidth*0.09, height: frameHeight*0.1), style: .circular)

//            context.fill(outLine, with: .linearGradient(gradient, startPoint: .zero, endPoint: CGPoint(x: frameWidth, y: frameHeight)))
//            context.fill(outLine, with: .color(color3))
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),

            ]), startPoint: CGPoint(x: frameWidth/2, y: 0), endPoint: CGPoint(x: frameWidth/2, y: frameHeight)))

            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.85),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2).opacity(0.0),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2).opacity(0.0),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2).opacity(0.0),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2).opacity(0.0),
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2).opacity(0.0),
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.85),

            ]), startPoint: CGPoint(x: xOrigin, y: frameHeight/2), endPoint: CGPoint(x: frameWidth+xOrigin, y: frameHeight/2)))

            
//            context.fill(outLine,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
//            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))
//
//            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
//            context.fill(bottomSides,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
//            context.fill(bottomCenter,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))
//
//
        }
        


    }

}


