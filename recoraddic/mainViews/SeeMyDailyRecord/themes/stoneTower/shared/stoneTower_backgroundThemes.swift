//
//  backgroundThemes_stoneTower.swift
//  recoraddic
//
//  Created by 김지호 on 1/27/24.
//

import Foundation
import SwiftUI

struct StoneTowerBackground:View {
    
    @Environment(\.colorScheme) private var colorScheme

    var backgroundThemeName: String
    var totalSkyHeight: CGFloat
    var groundHeight: CGFloat
    var displayHeight: CGFloat

    
    var body: some View {
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            if backgroundThemeName == "stoneTowerBackground_1" {
                StoneTowerBackground_1(totalSkyHeight: totalSkyHeight, groundHeight: groundHeight, displayHeight: displayHeight)
                    .frame(height: geoHeight)
            }
            
            else {
                StoneTowerBackground_1(totalSkyHeight: totalSkyHeight, groundHeight: groundHeight,displayHeight:displayHeight)
                    .frame(height: geoHeight)

            }

            
        }
    }


}


struct StoneTowerBackground_1:View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var totalSkyHeight: CGFloat
    var groundHeight: CGFloat
    var displayHeight: CGFloat
    
    
    var body: some View {
        
        let skyGradient: LinearGradient = {
            if colorScheme == .light {
                return LinearGradient(colors: [.blue.adjust(saturation: -0.4, brightness: 0.3),.blue.adjust(saturation: -0.45, brightness: 0.4),.blue.adjust(saturation: -0.5, brightness: 0.43),.blue.adjust(saturation: -0.52, brightness: 0.47)], startPoint: .top, endPoint: .bottom)
            }
            else {
                return LinearGradient(colors: [.blue.adjust(saturation: 0.5, brightness: -0.5),.blue.adjust(saturation: 0.7, brightness: -0.8)], startPoint: .top, endPoint: .bottom)
            }
                
            }()
        
        
        let groundGradient: LinearGradient = {
            if colorScheme == .light {
                let groundBaseColor: Color = Color.green.adjust(saturation:0.5,brightness: 0.5)
                return LinearGradient(colors: [groundBaseColor,groundBaseColor, groundBaseColor,groundBaseColor,groundBaseColor,groundBaseColor,groundBaseColor,.white], startPoint: .top, endPoint: .bottom)
            }
            else {
                
                let groundBaseColor: Color = Color.green.adjust(saturation:0.5,brightness: -0.57)

                return LinearGradient(colors: [groundBaseColor,groundBaseColor,groundBaseColor,groundBaseColor,groundBaseColor,groundBaseColor,groundBaseColor,.black], startPoint: .top, endPoint: .bottom)
            }

        }()
        
        
        
        GeometryReader { geometry in
            
//            let skySize: CGFloat = 5000
//            let skySize: CGFloat = displaySize * 2.5
//            let skySize: CGFloat = env.
            let skyGradientHeight: CGFloat = displayHeight * 2.5 // about 30 stones
//                .shared.connectedScenes
//                
//                .filter { $0.activationState == .foregroundActive }
//                .map { $0 as? UIWindowScene }
//                .compactMap { $0 }
//                .first?.windows
//                .filter { $0.isKeyWindow }
//                .first
//                .

        //    let height = window?.windowScene?.keyWindow?.frame.height
//            let height = window?.screen.bounds.height
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            
            VStack(spacing: 0.0) {
                if totalSkyHeight <= 5000 {
                    ZStack {
//                        LinearGradient(colors: [.blue.adjust(brightness: 0.2), .blue.adjust(brightness: 0.35),.blue.adjust(brightness: 0.5),.blue.adjust(brightness: 0.6),.blue.adjust(saturation:-0.05, brightness: 0.7),.blue.adjust(saturation:-0.3,brightness: 0.8),.white], startPoint: .top, endPoint: .bottom)
                        skyGradient
                            .frame(width:geoWidth, height: skyGradientHeight)
                            .mask {
                                Rectangle()
                                    .frame(width: geoWidth, height: totalSkyHeight)
                                    .position(x:geoWidth/2, y:skyGradientHeight-totalSkyHeight/2)
                            }
                            .position(x:geoWidth/2, y:totalSkyHeight-skyGradientHeight/2)
                    }
                    .frame(width: geoWidth, height:totalSkyHeight)
                }
                else {
                    VStack(spacing:0.0) {
                        
                        if colorScheme == .light {
                            Color.blue.adjust(saturation: -0.4, brightness: 0.3)
                                .frame(width:geoWidth, height: totalSkyHeight - skyGradientHeight)
                        }
                        else {
                        Color.blue.adjust(saturation: 0.5, brightness: -0.5)                                .frame(width:geoWidth, height: totalSkyHeight - skyGradientHeight)
                        }


//                        LinearGradient(colors: [.blue.adjust(brightness: 0.2), .blue.adjust(brightness: 0.35),.blue.adjust(brightness: 0.5),.blue.adjust(brightness: 0.6),.blue.adjust(saturation:-0.05, brightness: 0.7),.blue.adjust(saturation:-0.3,brightness: 0.8),.white], startPoint: .top, endPoint: .bottom)
                        skyGradient
                            .frame(width:geoWidth, height: skyGradientHeight)


                    }
                    .frame(width: geoWidth, height:totalSkyHeight)
                }


                        
                ZStack {
//                            LinearGradient(colors: [.brown.adjust(brightness: 0.1), .brown.adjust(brightness: 0.2),.brown.adjust(brightness: 0.2),.brown.adjust(brightness: 0.2),.brown.adjust(brightness: 0.2),.brown.adjust(brightness: 0.2)], startPoint: .top, endPoint: .bottom)
////                                .opacity(0.6)
//                            LinearGradient(colors: [.green.adjust(brightness: 0.2), .green.adjust(brightness: 0.3),.green.adjust(brightness: 0.3),.green.adjust(brightness: 0.3),.green.adjust(brightness: 0.3),.green.adjust(brightness: 0.3)], startPoint: .top, endPoint: .bottom)
//                                .opacity(0.6)
//                            Color.gray
//                                .opacity(0.6)
//                            Color.gray
                    
                    groundGradient
//                                .opacity(0.8)
                    if colorScheme == .light {
                        
//                        let browGradientBaseColor: Color = .brown.adjust(brightness: 0.2)
//                        LinearGradient(colors: [.brown.adjust(brightness: 0.1),browGradientBaseColor,browGradientBaseColor,browGradientBaseColor,browGradientBaseColor,browGradientBaseColor,browGradientBaseColor,.white], startPoint: .top, endPoint: .bottom)
//                            .opacity(0.2)
                        
                        LinearGradient(colors: [.gray.adjust(brightness: 0.2),.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white], startPoint: .top, endPoint: .bottom)
                            .opacity(0.45)
                    }
                    else {
//                        [.black,.black,.black,.black,.black,.black,.black,.black,.black,.black,.black,.black,.black,.black,.black,.black,.black,.black],
                        let brightBlack: Color = Color.black.opacity(0.5)
                        LinearGradient(colors: [.black, brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack,brightBlack], startPoint: .top, endPoint: .bottom)
                            .opacity(0.45)
                    }

                }
                .frame(width:geoWidth, height:groundHeight)



                
//                    .background(StoneTowerBackground_1.getSkyColor(colorScheme: colorScheme))
//                Spacer()

                //                    .background(
//                        LinearGradient(colors: [.green.adjust(brightness: 0.2), .green.adjust(brightness: 0.3),.green.adjust(brightness: 0.6),.green.adjust(brightness: 0.6),.green.adjust(brightness: 0.7),.green.adjust(brightness: 0.8)], startPoint: .top, endPoint: .bottom)
//                        )
//                    .background(StoneTowerBackground_1.getGroundColor(colorScheme: colorScheme))
            }
            .frame(height: totalSkyHeight + groundHeight)
            .onAppear() {
                print("height size: \(skyGradientHeight/2.5)")
            }
    

            
        }
    }
    
    static func getSkyColor(colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? .blue.adjust(saturation: -0.4, brightness: 0.3) : .blue.adjust(saturation: 0.5, brightness: -0.5)
    }
    
//    static func getGroundColor(colorScheme: ColorScheme) -> Color {
//        return colorScheme == .light ? .green.adjust(saturation:0.1, brightness:-0.1) : .green.adjust(brightness:-0.3)
//    }


}
