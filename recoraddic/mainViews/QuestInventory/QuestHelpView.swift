//
//  MountainHelpView.swift
//  recoraddic
//
//  Created by 김지호 on 10/26/24.
//
import Foundation
import SwiftUI


struct MountainHelpView: View {
    
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
//            .frame(height:40)
        }
        .padding(.vertical,20)
        .frame(width:UIScreen.main.bounds.width*0.9)

//                .padding(.vertical, geoHeight*0.02)
    }
}



//struct MountainHelpView: View {
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    @Binding var popUp_help: Bool
//    
//
//        let tierGuideLines: [String] = [
//            "0시간/회~",
//            "5시간/회~",
//            "10시간/회~",
//            "40시간/회~",
//            "100시간/회~",
//            "400시간/회~",
//            "1000시간/회~",
//            "4000시간/회~",
//            "10000시간/회~"
//        ]
//    
////    let momentumLevelDays:[Int:Int] = [1:1,3]
//    
//    let fireGuideLines: [String] = [
//        "1회",
//        "2회",
//        "3회",
//        "4회",
//        "5회",
//        "6회",
////        "최근 20일 중 8일 이상 실행",
////        "최근 30일 중 10일 이상 실행",
////        "최근 40일 중 12일 이상 실행",
////        "최근 50일 중 15일 이상 실행",
//        "1개월",
//        "2개월",
//        "3개월",
//        "6개월",
//        "1개월",
//        "2개월",
//        "3개월",
//        "6개월",
//        "1개월",
//        "2개월",
//        "3개월",
//        "6개월",
//        "7일",
//        "1개월",
//        "2개월",
//        "3개월",
//        "6개월",
//        "7일",
//        "1개월",
//        "2개월",
//        "3개월",
//        "6개월",
//        "3일",
//        "7일",
//        "1개월",
//        "2개월",
//        "3개월",
//        "6개월",
//    ]
//
//
//    var body: some View {
//        GeometryReader { geometry in
//            let geoWidth: CGFloat = geometry.size.width
//            let geoHeight: CGFloat = geometry.size.height
//            let tierViewSize: CGFloat = geoWidth*0.2
//            let fireViewSize: CGFloat = geoWidth*0.2
//            
//            VStack(spacing:0.0) {
//                Text("퀘스트 분류")
//                    .bold()
//                    .frame(height:40)
////                    .padding(.bottom,10)
//                HStack(alignment: .top) {
//                    VStack {
//                        Text("누적 등급")
//                            .font(.caption)
////                        Picker("", selection: $selectedOption, content: {
////                            ForEach(options,id:\.self) { option in
////                                Text(option)
////                            }
////                        })
//                        .labelsHidden()
//                        .pickerStyle(.segmented)
//                        ScrollView {
//                            ForEach(0...8, id:\.self) { tier in
//                                VStack {
//                                    MountainTierView(tier: tier*5, notUsedYet: false)
//                                        .frame(width:tierViewSize, height: tierViewSize)
////                                    Text(selectedOption == "시간x" ?  notHourTierGuideLines[tier]: hourTierGuideLines[tier])
////                                        .font(.caption)
//                                    Text(tierGuideLines[tier])
//                                        .font(.caption)
//                                        .foregroundStyle(colorScheme == .light ? getDarkTierColorOf(tier: tier*5) : getBrightTierColorOf(tier: tier*5))
//
//                                }
//                                .frame(width: geoWidth/2)
//                                .padding(.vertical,tierViewSize*0.1)
//                            }
//                        }
//                        .frame(width:geoWidth*0.5-21)
//                    }
//                    .padding(.horizontal,10)
//
//                    Spacer()
//                        .frame(width: 2,height: geoHeight-80)
////                        .containerRelativeFrame(.vertical)
//                        .background(.gray.opacity(0.5))
//                    
//                    
//                    
//                    VStack {
//                        Text("불꽃")
//                            .font(.caption)
//                        
//                        ScrollView(.vertical) {
//                            VStack {
//                                Text("기본 불꽃\n(최근 30일)")
//                                    .font(.caption)
//                                    .opacity(0.7)
//                                    .multilineTextAlignment(.center)
//
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack {
//                                        
//                                        ForEach(1...6, id:\.self) { momentumLevel in
//                                            VStack(spacing:0.0) {
//                                                FireView(momentumLevel: momentumLevel)
//                                                    .frame(width:fireViewSize, height: fireViewSize)
//                                                Text("\(fireGuideLines[momentumLevel-1])")
//                                                    .font(.caption2)
//                                                    .opacity(0.7)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(10)
//                            .background(.red.opacity(0.3))
//                            .clipShape(.buttonBorder)
//                            .padding(.bottom,30)
//                            
//                            VStack {
//                                Text("꾸준함의 불꽃 (20%)")
//                                    .font(.caption)
//                                    .opacity(0.7)
//                                    .multilineTextAlignment(.center)
//                                
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack {
//                                        ForEach(7...10, id:\.self) { momentumLevel in
//                                            VStack(spacing:0.0) {
//                                                FireView(momentumLevel: momentumLevel)
//                                                    .frame(width:fireViewSize, height: fireViewSize)
//                                                Text("\(fireGuideLines[momentumLevel-1])")
//                                                    .font(.caption2)
//                                                    .opacity(0.7)
//
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(10)
//                            .background(Color.yellow.opacity(0.2).background(.green.opacity(0.2)))
//                            .clipShape(.buttonBorder)
//                            .padding(.bottom,30)
//                            
//
//                            VStack {
//                                Text("꾸준함의 불꽃 (30%)")
//                                    .font(.caption)
//                                    .opacity(0.7)
//                                    .multilineTextAlignment(.center)
//
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack {
//                                        
//                                        ForEach(11...14, id:\.self) { momentumLevel in
//                                            VStack(spacing:0.0) {
//                                                FireView(momentumLevel: momentumLevel)
//                                                    .frame(width:fireViewSize, height: fireViewSize)
//                                                Text("\(fireGuideLines[momentumLevel-1])")
//                                                    .font(.caption2)
//                                                    .opacity(0.7)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(10)
////                            .background(.gray.opacity(0.2))
////                            .background(.cyan.opacity(0.3))
//                            .background(.mint.opacity(0.3))
//                            .clipShape(.buttonBorder)
//                            .padding(.bottom,30)
//                            
//                            VStack {
//                                Text("꾸준함의 불꽃 (50%)")
//                                    .font(.caption)
//                                    .opacity(0.7)
//                                    .multilineTextAlignment(.center)
//
//                                
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack {
//                                        
//                                        ForEach(15...18, id:\.self) { momentumLevel in
//                                            VStack(spacing:0.0) {
//                                                FireView(momentumLevel: momentumLevel)
//                                                    .frame(width:fireViewSize, height: fireViewSize)
//                                                Text("\(fireGuideLines[momentumLevel-1])")
//                                                    .font(.caption2)
//                                                    .opacity(0.7)
//                                            }
//                                        }
//                                    }
//                                }
//                                
//                            }
//                            .padding(10)
////                            .background(.gray.opacity(0.2))
//                            .background(.blue.opacity(0.3))
//                            .clipShape(.buttonBorder)
//                            .padding(.bottom,30)
//
//                            
//                            VStack {
//                                Text("열정의 불꽃 (70%)")
//                                    .font(.caption)
//                                    .opacity(0.7)
//                                    .multilineTextAlignment(.center)
//
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack {
//                                        
//                                        ForEach(19...23, id:\.self) { momentumLevel in
//                                            VStack(spacing:0.0) {
//                                                FireView(momentumLevel: momentumLevel)
//                                                    .frame(width:fireViewSize, height: fireViewSize)
//                                                Text("\(fireGuideLines[momentumLevel-1])")
//                                                    .font(.caption2)
//                                                    .opacity(0.7)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(10)
////                            .background(.gray.opacity(0.2))
//                            .background(.indigo.opacity(0.3))
//                            .clipShape(.buttonBorder)
//                            .padding(.bottom,30)
//                            
//                            
//                            VStack {
//                                Text("열정의 불꽃 (85%)")
//                                    .font(.caption)
//                                    .opacity(0.7)
//                                    .multilineTextAlignment(.center)
//
//                                
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack {
//                                        
//                                        ForEach(24...28, id:\.self) { momentumLevel in
//                                            VStack(spacing:0.0) {
//                                                FireView(momentumLevel: momentumLevel)
//                                                    .frame(width:fireViewSize, height: fireViewSize)
//                                                Text("\(fireGuideLines[momentumLevel-1])")
//                                                    .font(.caption2)
//                                                    .opacity(0.7)
//                                            }
//                                        }
//                                    }
//                                }
//                                
//                            }
//                            .padding(10)
////                            .background(.gray.opacity(0.2))
//                            .background(.purple.opacity(0.3))
//                            .clipShape(.buttonBorder)
//                            .padding(.bottom,30)
//                            
//                            
//                            VStack {
//                                Text("연속의 불꽃 (100%)")
//                                    .font(.caption)
//                                    .opacity(0.7)
//                                    .multilineTextAlignment(.center)
//
//                                
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack {
//                                        
//                                        ForEach(29...34, id:\.self) { momentumLevel in
//                                            VStack(spacing:0.0) {
//                                                FireView(momentumLevel: momentumLevel)
//                                                    .frame(width:fireViewSize, height: fireViewSize)
//                                                Text("\(fireGuideLines[momentumLevel-1])")
//                                                    .font(.caption2)
//                                                    .opacity(0.7)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(10)
////                            .background(.gray.opacity(0.2))
//                            .background(colorScheme == .light ? .black.opacity(0.3) : .white.opacity(0.3))
//                            .clipShape(.buttonBorder)
//                            .padding(.bottom,30)
//                            
//                            
//                            
//                            
//                            
//                            //                        ForEach(1...10, id:\.self) { momentumLevel in
//                            //
//                            //                            VStack {
//                            //
//                            //
//                            //                                FireView(momentumLevel: momentumLevel)
//                            //                                        .frame(width:fireViewSize, height: fireViewSize)
//                            //                                Text(fireGuideLines[momentumLevel-1])
//                            //                                    .font(.caption)
//                            //                            }
//                            //                            .frame(width: geoWidth/2)
//                            //                            .padding(.vertical,fireViewSize*0.1)
//                            //
//                            //                        }
//                        }
//                        .frame(width:geoWidth*0.5-21)
//                    }
//                    .padding(.horizontal,10)
//
//
//                }
////                .frame(width:geoWidth)
//                .frame(width:geoWidth, height: geoHeight-80)
//
//                Button(action:{
//                    popUp_help.toggle()
//                }) {
//                    Image(systemName: "xmark")
//                }
//                .frame(height:40)
////                .padding(.vertical, geoHeight*0.02)
//
//            }
//            .frame(width: geoWidth, height: geoHeight, alignment: .top)
//
//        }
//    }
//}
