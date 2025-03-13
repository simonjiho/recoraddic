//
//  QuestHelpView.swift
//  recoraddic
//
//  Created by 김지호 on 10/26/24.
//
import Foundation
import SwiftUI


struct QuestHelpView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var popUp_help: Bool
    
    var body: some View {
        
        let isDark: Bool = colorScheme == .dark
        
        
        VStack {
            
            Text("누적 기록량과 최근 기록빈도에 따라")
            Text("퀘스트의 모습이 변화합니다.")
            
            ScrollView(.horizontal) {
                VStack {
                    HStack(spacing: 0.0) {
                        ForEach(0...8, id:\.self) { i in
                            let tier = i * 5
                            let value:Int = (i%2 == 0 ? 1 : 5) * Int(pow(10.0,Double((i)/2)))
                            Text("\(value)회")
                                .foregroundStyle(isDark ? getBrightTierColorOf(tier: tier) : getDarkTierColorOf(tier: tier))
                                .frame(width:50*1.617,alignment: .leading)
                            
                        }
                        
                    }
                    
                    Rectangle().fill(
                        LinearGradient(colors: [
                            getTierColorOf(tier: 0),
                            getTierColorOf(tier: 0),
                            getTierColorOf(tier: 0),
                            //                getTierColorOf(tier: 0),
                            getTierColorOf(tier: 5),
                            getTierColorOf(tier: 5),
                            getTierColorOf(tier: 5),
                            //                getTierColorOf(tier: 5),
                            getTierColorOf(tier: 10),
                            getTierColorOf(tier: 10),
                            getTierColorOf(tier: 10),
                            //                getTierColorOf(tier: 10),
                            getTierColorOf(tier: 15),
                            getTierColorOf(tier: 15),
                            getTierColorOf(tier: 15),
                            //                getTierColorOf(tier: 15),
                            getTierColorOf(tier: 20),
                            getTierColorOf(tier: 20),
                            getTierColorOf(tier: 20),
                            //                getTierColorOf(tier: 20),
                            getTierColorOf(tier: 25),
                            getTierColorOf(tier: 25),
                            getTierColorOf(tier: 25),
                            //                getTierColorOf(tier: 25),
                            getTierColorOf(tier: 30),
                            getTierColorOf(tier: 30),
                            getTierColorOf(tier: 30),
                            //                getTierColorOf(tier: 30),
                            getTierColorOf(tier: 35),
                            getTierColorOf(tier: 35),
                            getTierColorOf(tier: 35),
                            //                getTierColorOf(tier: 35),
                            getTierColorOf(tier: 40),
                            getTierColorOf(tier: 40),
                            getTierColorOf(tier: 40),
                            //                getTierColorOf(tier: 40)
                        ], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width:50*1.617*9, height:50)
                    
                    
                    
                }
                HStack(spacing: 0.0) {
                    ForEach(0...8, id:\.self) { i in
                        let tier = i * 5
                        let value:Int = (i%2 == 0 ? 1 : 5) * Int(pow(10.0,Double((i)/2)))
                        Text("\(value)시간")
                            .foregroundStyle(isDark ? getBrightTierColorOf(tier: tier) : getDarkTierColorOf(tier: tier))
                            .frame(width:50*1.617,alignment: .leading)
                        
                    }
                    
                }
            }
            .font(.caption)
            .bold()
            .padding(.vertical,20)

        //        .scrollIndicators(.visi)

            
            
            HStack(spacing:0.0) {
                ForEach(0...3, id:\.self) { i in
                    let text:String = {
                        if i == 0 {return "10%"}
                        if i == 1 {return "33%"}
                        if i == 2 {return "66%"}
                        else {return "매일"}
                    }()
                    VStack(spacing:5.0) {
                        let textColor_dark:Color = {
                            if i == 0 {return Color.red.adjust(brightness: 1.3)}
                            if i == 1 {return Color.yellow.adjust(brightness: 0.05)}
                            if i == 2 {return Color.blue.adjust(brightness: 0.6)}
                            else {return Color.purple.adjust(brightness: 0.25)}
                        }()
                        let textColor_light:Color = {
                            if i == 0 {return Color.red.adjust(brightness: -0.2)}
                            if i == 1 {return Color.yellow.adjust(brightness: -0.3)}
                            if i == 2 {return Color.blue.adjust(brightness: -0.2)}
                            else {return Color.purple.adjust(brightness: -0.2)}
                        }()
                        FireView(momentumLevel: 5+i*6)
                            .frame(width:50, height:50)
                        Text(text)
                            .font(.caption)
                            .foregroundStyle(isDark ? textColor_dark : textColor_light)
                            .bold()
                            .opacity(0.7)
                    }
                    .padding(.horizontal,10)
                    .padding(.vertical,5)
                        
                    
                }
                
            }
            .background(
                LinearGradient(colors: [
                    .red.adjust(brightness:0.5).colorExpressionIntegration(),
                    .red.adjust(brightness:0.5).colorExpressionIntegration(),
                    .yellow.adjust(brightness:0.5).colorExpressionIntegration(),
                    .yellow.adjust(brightness:0.5).colorExpressionIntegration(),
                    .blue.adjust(brightness:0.5).colorExpressionIntegration(),
                    .blue.adjust(brightness:0.5).colorExpressionIntegration(),
                    .purple.adjust(brightness:0.5).colorExpressionIntegration(),
                    .purple.adjust(brightness:0.5).colorExpressionIntegration()
                ], startPoint: .leading, endPoint: .trailing
                )
                .opacity(0.3)
            )
            
            
            Button(action:{
                popUp_help.toggle()
            }) {
                Image(systemName: "xmark")
            }
            .padding(.top,20)
        }
        .padding(.vertical,20)
        .frame(width:UIScreen.main.bounds.width*0.9)

    }
}
