//
//  StoneTower1_stones.swift
//  recoraddic
//
//  Created by 김지호 on 3/26/24.
//

// MARK: Path rules: start from top left, clockwise

import Foundation
import SwiftUI

struct StoneTower_1_stone: View {
    
    @Environment(\.colorScheme) var colorScheme
    // themeName, visualValue1, visualValue2
    var shapeNum: Int
    var brightness: Int
    var facialExpressionNum: Int
    
    var defaultColor:Color
    
    var selected: Bool

    
    init(shapeNum: Int, brightness: Int, defaultColorIndex: Int, facialExpressionNum: Int, selected:Bool) {
        self.shapeNum = shapeNum
        self.brightness = brightness
        self.facialExpressionNum = facialExpressionNum
        self.defaultColor = StoneTower_1.getDailyRecordColor(index: defaultColorIndex)
        self.selected = selected
    }


    
    var body: some View {

        let stoneColor: Color = {
            // later control saturation
            let mainColorDarkness: CGFloat = {
                let mainColor_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = defaultColor.getRGBA()
    //            print("0: ",mainColor_rgba.0)
    //            print("1: ",mainColor_rgba.1)
    //            print("2: ",mainColor_rgba.2)
                print(3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2)
                return 3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2
            }()
            
            let shouldBeDarkerInDarkStoneInDarkMode: Bool = mainColorDarkness > 0.001 && colorScheme == .dark
            
            switch brightness {
            case 3: return defaultColor.adjust(brightness: colorScheme == .light ? -0.02 : -0.25)
            case 2: return defaultColor.adjust(brightness: colorScheme == .light ? -0.08 : -0.38)
            case 1: return defaultColor.adjust(brightness: colorScheme == .light ? -0.14 : -0.51)
            case 0: return defaultColor.adjust(brightness: colorScheme == .light ? -0.27 : -0.64)
            case -1: return defaultColor.adjust(brightness: colorScheme == .light ? -0.39 : (shouldBeDarkerInDarkStoneInDarkMode ? -0.8 : -0.70))
            case -2: return defaultColor.adjust(brightness: colorScheme == .light ? -0.47 : (shouldBeDarkerInDarkStoneInDarkMode ? -0.9 : -0.75))
            case -3: return defaultColor.adjust(brightness: colorScheme == .light ? -0.55 : (shouldBeDarkerInDarkStoneInDarkMode ? -1.0 : -0.80))

            default: return Color.red
            }
        }()


        
        GeometryReader { geometry in
            
            
//            let geoWidth = geometry.size.width
//            let geoHeight = geometry.size.height

            
            ZStack {
                // TODO: 그림자를 그 다음 stone과의 visualValue3 차이만큼 받아서 적용, nil이면 그림자 없음

                switch shapeNum {
                case 0:
                    StoneShape0(mainColor: stoneColor)
                        .opacity(0.85)
                case 1:
                    StoneShape1(mainColor: stoneColor)
                        .opacity(0.85)
                case 2:
                    StoneShape2(mainColor: stoneColor)
                        .opacity(0.85)
                case 3:
                    StoneShape3(mainColor: stoneColor)
                        .opacity(0.85)
                default:
                    Text("ERROR")
                }
//                if shapeNum == 0 {
//                    StoneShape0(mainColor: stoneColor)
//                }

                
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
                        .opacity(selected ? 0.7 : 0.3)




                }
                
            }   // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }

    }
        
    
    
    

    

    
    
    
    
    
        
}


struct RecordStoneShadowView: View {
    var adjustedThemeSet: ThemeSet
    var dailyRecordThemeNum: Int
    
    
    var body: some View {
        
        GeometryReader { geometry in
            let shapeNum = dailyRecordThemeNum >= 0 ? dailyRecordThemeNum : 0
            
            let shape: Path = {
                var returnShape: Path? = nil
                if shapeNum <= 2 {
                    returnShape = Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        path.addLines(
                            {
                                var returnList:[CGPoint] = []
                                for ratio in adjustedThemeSet.shapes[shapeNum]!  {
                                    returnList.append(CGPoint(x: ratio.x * width, y: ratio.y * height))
                                }
                                return returnList
                            }()
                        )
                        path.closeSubpath()
                    }
                    
                }
                else {
                    returnShape = Path(roundedRect: CGRect(x:0, y:0,width: geometry.size.width, height: geometry.size.height), cornerSize: CGSize(width: geometry.size.width*0.1, height:geometry.size.height*0.1))
                    
                }
                
                return returnShape!
                
                
            }()
            
            
            
            
            ZStack {

                
                Color.white
                    .clipShape(shape)
                    .shadow(radius: 7)
                
                
                
            }   // zstack
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }

    }
}


//struct FacialExpressionView_CreatePhase: View {
//
//    @Binding var list: [Int]
//    var list_inside: [Int]
//    @Binding var index: Int
//
//    var body: some View {
//        Image
//    }
//}
//




struct StoneShape0: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let point1:CGPoint = CGPoint(x: 0.30, y: 0.00)
    let point2:CGPoint = CGPoint(x: 0.70, y: 0.00)
    let point3:CGPoint = CGPoint(x: 0.90, y: 0.55)
    let point4:CGPoint = CGPoint(x: 0.70, y: 1.00)
    let point5:CGPoint = CGPoint(x: 0.30, y: 1.00)
    let point6:CGPoint = CGPoint(x: 0.10, y: 0.55)
    // outer point (order: topLeft, clockwise)

    
    let point7:CGPoint = CGPoint(x: 0.35, y: 0.15)
    let point8:CGPoint = CGPoint(x: 0.65, y: 0.15)
    let point9: CGPoint = CGPoint(x: 0.75, y: 0.60)
    let point10:CGPoint = CGPoint(x: 0.65, y: 0.90)
    let point11:CGPoint = CGPoint(x: 0.35, y: 0.90)
    let point12:CGPoint = CGPoint(x: 0.25, y: 0.60)

    
    // inner point (order: topLeft, clockwise)
    
    /*
            1 ------------- 2
          /   \           /   \
         /     7 ------- 8     \
        /     /           \     \
       6 --- 12            9 --- 3
        \     \           /     /
         \     11 ----- 10     /
          \   /            \  /
            5 -------------- 4
     
     */
    
    var mainColor: Color
    
    var body: some View {
        
        let color1 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.03 : 0.1)
        let color2 = mainColor.adjust(saturation:-0.02, brightness: colorScheme == .light ? 0.015 : 0.05)
        let color3 = mainColor
        let color4 = mainColor.adjust(brightness: colorScheme == .light ? -0.03 : -0.05)
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.06 : -0.10)

        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        
        let outLinePoints: [CGPoint] = [point1, point2, point3, point4, point5, point6]
        let topCenterPoints: [CGPoint] = [
            point1, point2, point8, point7
        ]
        let topLeftPoints: [CGPoint] = [
            point1, point7, point12, point6
        ]
        let topRightPoints: [CGPoint] = [
            point2, point3, point9, point8
        ]
        let bottomCenterPoints: [CGPoint] = [
            point11, point10, point4, point5
        ]
        let bottomLeftPoints: [CGPoint] = [
            point6, point12, point11, point5, point6
        ]
        let bottomRightPoints: [CGPoint] = [
            point9, point3, point4, point10
        ]
        Canvas { context, size in
            let frameWidth = size.width
            let frameHeight = size.height
            context.blendMode = .copy
            context.opacity = 1.0
            
            let outLine:Path = Path { path in
                path.addLines(outLinePoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }            
            let topCenter:Path = Path { path in
                path.addLines(topCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides:Path = Path { path in
                path.addLines(topLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomCenter:Path = Path { path in
                path.addLines(bottomCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides:Path = Path { path in
                path.addLines(bottomLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            
            context.fill(outLine,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))

            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
            context.fill(bottomSides,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
            context.fill(bottomCenter,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))

            
        }
        


    }

}


struct StoneShape1: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let point1:CGPoint = CGPoint(x: 0.27, y: 0.00)
    let point2:CGPoint = CGPoint(x: 0.73, y: 0.00)
    let point3:CGPoint = CGPoint(x: 0.88, y: 0.30)
    let point4:CGPoint = CGPoint(x: 0.88, y: 0.80)
    let point5:CGPoint = CGPoint(x: 0.77, y: 1.00)
    let point6:CGPoint = CGPoint(x: 0.23, y: 1.00)
    let point7:CGPoint = CGPoint(x: 0.12, y: 0.80)
    let point8:CGPoint = CGPoint(x: 0.12, y: 0.30)
    // outer point (order: topLeft, clockwise)

    
    let point9: CGPoint = CGPoint(x: 0.32, y: 0.10)
    let point10:CGPoint = CGPoint(x: 0.68, y: 0.10)
    let point11:CGPoint = CGPoint(x: 0.82, y: 0.40)
    let point12:CGPoint = CGPoint(x: 0.82, y: 0.70)
    let point13:CGPoint = CGPoint(x: 0.70, y: 0.88)
    let point14:CGPoint = CGPoint(x: 0.30, y: 0.88)
    let point15:CGPoint = CGPoint(x: 0.18, y: 0.70)
    let point16:CGPoint = CGPoint(x: 0.18, y: 0.40)


    
    // inner point (order: topLeft, clockwise)
    
    /*
                 1       2
                  9    10
            8                 3
               16         11
                         
               15         12
            7    14     13    4
                6         5
    
     
     */
    
    var mainColor: Color
    
    var body: some View {
        
        
        let color1 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.03 : 0.1)
        let color2 = mainColor.adjust(saturation:-0.03, brightness: colorScheme == .light ? 0.015 : 0.05)
        let color3 = mainColor
        let color4 = mainColor.adjust(brightness: colorScheme == .light ? -0.03 : -0.05)
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.06 : -0.10)
        let color6 = mainColor.adjust(brightness: colorScheme == .light ? -0.09 : -0.13)


        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        let color6_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color6.getRGBA()

        
        let outLinePoints: [CGPoint] = [point1, point2, point3, point4, point5, point6, point7, point8]
        let topCenterPoints: [CGPoint] = [
            point1, point2, point10, point9
        ]
        let topLeftPoints: [CGPoint] = [
            point1, point9, point16, point8
        ]
        let topRightPoints: [CGPoint] = [
            point2, point3, point11, point10
        ]
        let centerLeftPoints: [CGPoint] = [ point8, point16, point15, point7 ]
        let centerRightPoints: [CGPoint] = [ point11, point3, point4, point12 ]
        let bottomCenterPoints: [CGPoint] = [
            point14, point13, point5, point6
        ]
        let bottomLeftPoints: [CGPoint] = [
            point15, point14, point6, point7
        ]
        let bottomRightPoints: [CGPoint] = [
            point12, point4, point5, point13
        ]
        Canvas { context, size in
            let frameWidth = size.width
            let frameHeight = size.height
            context.blendMode = .copy
            context.opacity = 1.0
            
            let outLine:Path = Path { path in
                path.addLines(outLinePoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topCenter:Path = Path { path in
                path.addLines(topCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides:Path = Path { path in
                path.addLines(topLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let centerSides: Path = Path { path in
                path.addLines(centerLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(centerRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomCenter:Path = Path { path in
                path.addLines(bottomCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides:Path = Path { path in
                path.addLines(bottomLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            
            context.fill(outLine,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))
            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
            context.fill(centerSides,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
            context.fill(bottomSides,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))
            context.fill(bottomCenter,with: .color(red:color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2))

            
        }
        


    }

}


//#Preview(body: {
//    ZStack {
//        StoneShape2(mainColor:Color.white.adjust(brightness: -0.03))
//            .frame(width:210, height:140)
//    }
//    .padding(20)
//    .background(.gray)
//})

struct StoneShape2: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let point1:CGPoint = CGPoint(x: 0.24, y: 0.00)
    let point2:CGPoint = CGPoint(x: 0.76, y: 0.00)
    let point3:CGPoint = CGPoint(x: 0.85, y: 0.10)
    let point4:CGPoint = CGPoint(x: 0.93, y: 0.35)
    let point5:CGPoint = CGPoint(x: 0.93, y: 0.65)
    let point6:CGPoint = CGPoint(x: 0.85, y: 0.93)
    let point7:CGPoint = CGPoint(x: 0.76, y: 1.00)
    let point8:CGPoint = CGPoint(x: 0.24, y: 1.00)
    let point9:CGPoint = CGPoint(x: 0.15, y: 0.93)
    let point10:CGPoint = CGPoint(x: 0.07, y: 0.65)
    let point11:CGPoint = CGPoint(x: 0.07, y: 0.35)
    let point12:CGPoint = CGPoint(x: 0.15, y: 0.10)

    
    
//    let point13:CGPoint = CGPoint(x: 0.27, y: 0.08)
//    let point14:CGPoint = CGPoint(x: 0.73, y: 0.08)
//    let point15:CGPoint = CGPoint(x: 0.79, y: 0.15)
//    let point16:CGPoint = CGPoint(x: 0.85, y: 0.33)
//    let point17:CGPoint = CGPoint(x: 0.85, y: 0.67)
//    let point18:CGPoint = CGPoint(x: 0.79, y: 0.85)
    let point13:CGPoint = CGPoint(x: 0.31, y: 0.10)
    let point14:CGPoint = CGPoint(x: 0.69, y: 0.10)
    let point15:CGPoint = CGPoint(x: 0.78, y: 0.18)
    let point16:CGPoint = CGPoint(x: 0.85, y: 0.36)
    let point17:CGPoint = CGPoint(x: 0.85, y: 0.64)
    let point18:CGPoint = CGPoint(x: 0.80, y: 0.82)

//    let point19:CGPoint = CGPoint(x: 0.70, y: 0.95)
//    let point20:CGPoint = CGPoint(x: 0.30, y: 0.95)
//    let point21:CGPoint = CGPoint(x: 0.21, y: 0.85)
//    let point22:CGPoint = CGPoint(x: 0.15, y: 0.67)
//    let point23:CGPoint = CGPoint(x: 0.15, y: 0.33)
//    let point24:CGPoint = CGPoint(x: 0.21, y: 0.15)
    let point19:CGPoint = CGPoint(x: 0.71, y: 0.94)
    let point20:CGPoint = CGPoint(x: 0.29, y: 0.94)
    let point21:CGPoint = CGPoint(x: 0.20, y: 0.82)
    let point22:CGPoint = CGPoint(x: 0.15, y: 0.64)
    let point23:CGPoint = CGPoint(x: 0.15, y: 0.36)
    let point24:CGPoint = CGPoint(x: 0.22, y: 0.18)

    
    // inner point (order: topLeft, clockwise)
    
    /*
             1         2
             13       14
      12  24              15 3
      
    11  23                  16  4
     
    10  22                  17  5
          21              18
       9       20    19      6
             8          7
     
     */
    
    var mainColor: Color
    
    var body: some View {
        
        let color1 = mainColor.adjust(saturation:-0.07, brightness: colorScheme == .light ? 0.03 : 0.1)
        let color2 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.02 : 0.07)
        let color3 = mainColor.adjust(saturation:-0.03, brightness: colorScheme == .light ? 0.01 : 0.035)
        let color4 = mainColor
        let color5 = mainColor.adjust(brightness: colorScheme == .light ? -0.02 : -0.03)
        let color6 = mainColor.adjust(brightness: colorScheme == .light ? -0.04 : -0.06)
        let color7 = mainColor.adjust(brightness: colorScheme == .light ? -0.065 : -0.09)
        let color8 = mainColor.adjust(brightness: colorScheme == .light ? -0.09 : -0.12)

        let color1_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color1.getRGBA()
        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        let color6_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color6.getRGBA()
        let color7_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color7.getRGBA()
        let color8_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color8.getRGBA()

        
        let outLinePoints: [CGPoint] = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12]
        let topCenterPoints: [CGPoint] = [
            point1, point2, point14, point13
        ]
        let topLeftPoints: [CGPoint] = [
            point1, point13, point24, point12
        ]
        let topRightPoints: [CGPoint] = [
            point2, point3, point15, point14
        ]
        let topLeftPoints2: [CGPoint] = [
            point12, point24, point23, point11
        ]
        let topRightPoints2: [CGPoint] = [
            point15, point3, point4, point16
        ]
        let centerLeftPoints: [CGPoint] = [
            point11, point23, point22, point10
        ]
        let centerRightPoints: [CGPoint] = [
            point16, point4, point5, point17
        ]
        let bottomLeftPoints: [CGPoint] = [
            point10, point22, point21, point9
        ]
        let bottomRightPoints: [CGPoint] = [
            point17, point5, point6, point18
        ]
        let bottomLeftPoints2: [CGPoint] = [
            point21, point20, point8, point9
        ]
        let bottomRightPoints2: [CGPoint] = [
            point18, point6, point7, point19
        ]
        let bottomCenterPoints: [CGPoint] = [
            point20, point19, point7, point8
        ]
        Canvas { context, size in
            let frameWidth = size.width
            let frameHeight = size.height
            context.blendMode = .copy
            context.opacity = 1.0
            
            let outLine:Path = Path { path in
                path.addLines(outLinePoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topCenter:Path = Path { path in
                path.addLines(topCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides:Path = Path { path in
                path.addLines(topLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let topSides2:Path = Path { path in
                path.addLines(topLeftPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(topRightPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let centerSides:Path = Path { path in
                path.addLines(centerLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(centerRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomCenter:Path = Path { path in
                path.addLines(bottomCenterPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides:Path = Path { path in
                path.addLines(bottomLeftPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            let bottomSides2:Path = Path { path in
                path.addLines(bottomLeftPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
                path.addLines(bottomRightPoints2.map({ ratio in
                    CGPoint(x: frameWidth*ratio.x, y: frameHeight*ratio.y)}))
                path.closeSubpath()
            }
            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                Color(red: color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
                Color(red: color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2),
//                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
//                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
//                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2),

            ]), startPoint: CGPoint(x: frameWidth/2, y: frameHeight*0.09), endPoint: CGPoint(x: frameWidth/2, y: frameHeight*0.93)))

//            context.fill(outLine, with: .radialGradient(Gradient(colors: [
//                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
////                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
////                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
//                Color(red: color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2),
//
//            ]), center: CGPoint(x: frameWidth/2, y: frameHeight/5), startRadius: 0, endRadius: frameWidth/2))

//            context.fill(outLine,with: .color(red:color4_rgba.0, green: color4_rgba.1, blue: color4_rgba.2))
            context.fill(topCenter,with: .color(red:color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2))
            context.fill(topSides,with: .color(red:color2_rgba.0, green: color2_rgba.1, blue: color2_rgba.2))
            context.fill(topSides2,with: .color(red:color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2))
            context.fill(centerSides,with: .color(red:color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2))
            context.fill(bottomSides,with: .color(red:color6_rgba.0, green: color6_rgba.1, blue: color6_rgba.2))
            context.fill(bottomSides2,with: .color(red:color7_rgba.0, green: color7_rgba.1, blue: color7_rgba.2))
            context.fill(bottomCenter,with: .color(red:color8_rgba.0, green: color8_rgba.1, blue: color8_rgba.2))

            
        }
        


    }

}


struct StoneShape3: View {
    
    @Environment(\.colorScheme) var colorScheme
    



    
    var mainColor: Color
    
    var body: some View {
        
        let mainColorDarkness: CGFloat = {
            let mainColor_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = mainColor.getRGBA()
//            print("0: ",mainColor_rgba.0)
//            print("1: ",mainColor_rgba.1)
//            print("2: ",mainColor_rgba.2)
//            print(3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2)
            return 3 - mainColor_rgba.0 - mainColor_rgba.1 - mainColor_rgba.2
        }()

        
        let color1 = {
            if mainColorDarkness > 0.2 {
                return mainColor.adjust(saturation:-0.06, brightness: colorScheme == .light ? 0.08 : 0.07)
            }
            else {
//                return mainColor.adjust(saturation:-0.04, brightness: 0.03)
//                print("hoho")
                return mainColor.adjust(saturation:-0.045, brightness: colorScheme == .light ? 0.08 : 0.07)

            }
        }()
//        let color1 = mainColor.adjust(saturation:-0.05, brightness: colorScheme == .light ? 0.08 : 0.07)

//        let color2 = mainColor.adjust(brightness: colorScheme == .light ? 0.015 : 0.05)
//        let color3 = mainColor
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
//        let color2_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color2.getRGBA()
        let color3_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color3.getRGBA()
//        let color4_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color4.getRGBA()
        let color5_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color5.getRGBA()
        
        

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
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2),
                Color(red: color5_rgba.0, green: color5_rgba.1, blue: color5_rgba.2),

            ]), startPoint: CGPoint(x: frameWidth/2, y: 0), endPoint: CGPoint(x: frameWidth/2, y: frameHeight)))

            context.fill(outLine, with: .linearGradient(Gradient(colors: [
                Color(red: color1_rgba.0, green: color1_rgba.1, blue: color1_rgba.2).opacity(0.85),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
                Color(red: color3_rgba.0, green: color3_rgba.1, blue: color3_rgba.2).opacity(0.0),
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





















//let color_example: Color = Color.white.adjust(brightness: -0.4)
//let color_example2: Color = Color.white.adjust(brightness: -0.1)
//
//let color_ex_rgba: (CGFloat, CGFloat, CGFloat, CGFloat) = color_example.getRGBA()
//
////#Preview(body: {
////    VStack {
////        Color.white
////        Color.white.adjust(brightness: -0.1).adjust(brightness: 0.1)
////        color_example2.adjust(brightness: 0.1)
////        Canvas { context, size in
////            context.blendMode = .copy
////            context.opacity = 1.0
////            context.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerSize: CGSize(width: 5, height: 5)), with: .color(red: color_ex_rgba.0, green: color_ex_rgba.1, blue: color_ex_rgba.2))
//////            context.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerSize: CGSize(width: 5, height: 5)), with: .color(.blue.opacity(0.5)))
////        }
//////        Color.blue.opacity(0.5)
////        color_example
////        Color.white.adjust(brightness: -0.05)
////        Color.white.adjust(brightness: -0.05).adjust(brightness: -0.05)
////        Color.white.adjust(brightness: -0.1)
////        Color.white.adjust(brightness: -0.35).adjust(brightness: -0.35)
////        Color.white.adjust(brightness: -0.7)
////        
////
////        
////    }
////    .border(.red)
////})
