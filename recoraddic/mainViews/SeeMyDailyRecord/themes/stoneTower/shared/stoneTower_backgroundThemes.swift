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
    
    @State var isAnimating: Bool = false
    
    @State var cloudPosX:CGFloat = 0
    @State var cloudPosY:CGFloat = 0
    
    var body: some View {
        
        let skyGradient: LinearGradient = {
            if colorScheme == .light {
                return LinearGradient(colors: [.blue.adjust(saturation: -0.4, brightness: 0.3),.blue.adjust(saturation: -0.45, brightness: 0.4),.blue.adjust(saturation: -0.5, brightness: 0.43),.blue.adjust(saturation: -0.52, brightness: 0.47)], startPoint: .top, endPoint: .bottom)
            }
            else {
                return LinearGradient(colors: [.blue.adjust(saturation: 0.5, brightness: -0.5),.blue.adjust(saturation: 0.7, brightness: -0.9)], startPoint: .top, endPoint: .bottom)
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

            let skyGradientHeight: CGFloat = displayHeight * 2.5 // about 30 stones

            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let cloudUnitPosY = totalSkyHeight * 0.8 / 15
            let randomCloudPosY = 10
            

            
            ZStack {
                VStack(spacing: 0.0) {
                    if totalSkyHeight <= 5000 {
                        ZStack {
                            
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
                            
                            skyGradient
                                .frame(width:geoWidth, height: skyGradientHeight)
                            
                            
                        }
                        .frame(width: geoWidth, height:totalSkyHeight)
                    }
                    
                    
                    
                    ZStack {
                        
                        groundGradient
                        if colorScheme == .light {
                            
//                            let lightBlue = Color.blue.adjust(saturation: -0.52, brightness: 0.47).opacity(0.2)
                            let lightBlue = Color.blue.adjust(saturation: -0.45, brightness: 0.4).opacity(0.3)
                            
                            LinearGradient(colors: [lightBlue,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white,.white], startPoint: .top, endPoint: .bottom)
                                .opacity(0.45)
                        }
                        else {
                            
                            
//                            let brightBlack: Color = Color.black.opacity(0.5)
                            let darkBlue = Color.blue.adjust(saturation: 0.7, brightness: -0.75).opacity(0.3)
                            let darkBlack: Color = Color.black.opacity(0.7)
                            
                            LinearGradient(colors: [darkBlue,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack,darkBlack], startPoint: .top, endPoint: .bottom)
                            //                            .opacity(0.6)
                        }
                        
                    }
                    .frame(width:geoWidth, height:groundHeight)
                    
                    
                    
                }
                .frame(height: totalSkyHeight + groundHeight)
                
                Image(systemName: "cloud.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    
                    .frame(width: geoWidth/5)
                    .foregroundStyle(colorScheme == .light ? .white : .gray)
                    .opacity(0.5)
                    .position(x:isAnimating ? -geoWidth*0.2 : geoWidth*1.2, y: totalSkyHeight/2 )
                    .animation(.linear(duration: 25.0).repeatForever(autoreverses: false), value: isAnimating)
                    .onAppear() {
                        isAnimating = true
                    }
                    

            }
            .frame(height: totalSkyHeight + groundHeight)

    

            
        }
    }
    
    static func getSkyColor(colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? .blue.adjust(saturation: -0.4, brightness: 0.3) : .blue.adjust(saturation: 0.5, brightness: -0.5)
    }
    


}
