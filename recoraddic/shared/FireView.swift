//
//  fireViews.swift
//  recoraddic
//
//  Created by 김지호 on 2/9/24.
//

//let size1Ratio:CGFloat = 0.95*0.85*0.85
//let size2Ratio:CGFloat = 0.95*0.85*0.85
//let size3Ratio:CGFloat = 0.95*0.85*0.85
//let size4Ratio:CGFloat = 0.95*0.85
//let size5Ratio:CGFloat = 0.95
//let size6Ratio:CGFloat = 1.0
//
//let size1fps:CGFloat = 36.0
//let size2fps:CGFloat = 48.0
//let size3fps:CGFloat = 60.0
//let size4fps:CGFloat = 120.0
//let size5fps:CGFloat = 160.0
//let size6fps:CGFloat = 240.0
//
//let fireSize:[Int:Int] = [
//    1:1,2:1,3:2,4:2,5:3,6:3,
//    7:3,8:4,9:5,10:6,
//    11:3,12:4,13:5,14:6,
//    15:3,16:4,17:5,18:6,
//    19:2,20:3,21:4,22:5,23:6,
//    24:2,25:3,26:4,27:5,28:6,
//    29:1,30:2,31:3,32:4,33:5,34:6
//]
//
//func frameCount(momentumLevel:Int) -> Int {
//    switch fireSize[momentumLevel] {
//    case 1: return 36
//    case 2: return 36
//    case 3: return 24
//    case 4: return 24
//    case 5: return 16
//    case 6: return 16
//    default: return 16
//    }
//}
//
//func fireSizeRatio(momentumLevel:Int) -> CGFloat {
//    switch fireSize[momentumLevel] {
//    case 1: return size1Ratio
//    case 2: return size2Ratio
//    case 3: return size3Ratio
//    case 4: return size4Ratio
//    case 5: return size5Ratio
//    case 6: return size6Ratio
//    default: return 1.0
//    }
//}
//
//func fps(momentumLevel:Int) -> CGFloat {
//    switch fireSize[momentumLevel] {
//    case 1: return size1fps
//    case 2: return size2fps
//    case 3: return size3fps
//    case 4: return size4fps
//    case 5: return size5fps
//    case 6: return size6fps
//    default: return 60.0
//    }
//}



let fireSize:[Int:Int] = [
    1:1,2:1,3:2,4:2,5:3,6:3,
    7:3,8:4,9:5,10:6,
    11:3,12:4,13:5,14:6,
    15:3,16:4,17:5,18:6,
    19:2,20:3,21:4,22:5,23:6,
    24:2,25:3,26:4,27:5,28:6,
    29:1,30:2,31:3,32:4,33:5,34:6
]


func fireSizeRatio(momentumLevel:Int) -> CGFloat {
    
    if momentumLevel == 0 { return 0.7}
    
    switch momentumLevel%6 {
    case 1: return 0.7
    case 2: return 0.74
    case 3: return 0.79
    case 4: return 0.85
    case 5: return 0.91
    case 0: return 1.0
    default: return 0.7
    }
}

func fps(momentumLevel:Int) -> CGFloat {
    switch (momentumLevel+5)/6 {
    case 1: return 9
    case 2: return 14
    case 3: return 19
    case 4: return 24
    default: return 9
    }
}

import SwiftUI


#Preview(body: {
    ScrollView {
        VStack {
            ForEach(0...24, id:\.self) { i in
                FireView(momentumLevel: i)
                    .frame(width:100, height:100)
            }
        }
        
    
    }
})
struct FireView: View {
    
    let momentumLevel: Int
    @State var timer: Timer?
    @State var frameIndex: Int = 0

    
    var body: some View {

        GeometryReader { geometry in
//            if momentumLevel == 0 {
//                Image("fire0")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: geometry.size.width*0.7, height: geometry.size.height*0.7)
//                    .position(x:geometry.size.width/2, y:geometry.size.height/2)
////                    .opacity(0.4)

//            } else {
                let fps = fps(momentumLevel: momentumLevel)
                let frameCount = 6
                let sizeRatio = fireSizeRatio(momentumLevel: momentumLevel)
                
                Image("fire\((momentumLevel+5)/6)_frame\(frameIndex+1)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width*sizeRatio, height: geometry.size.height*sizeRatio)
                //                .blur(radius: 1)
                    .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                    .border(.red)

                    .onAppear() {
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / fps, repeats: true) { _ in
                            frameIndex = (frameIndex + 1) % frameCount
                        }
                        RunLoop.current.add(timer!, forMode: .common)
                        
                    }
                    .onDisappear() {
                        timer?.invalidate()
                        timer = nil
                        
                    }
                    .opacity(momentumLevel == 0 ? 0.7 : 1.0)
//            }
                
        }

    }
}

//struct FireView: View {
//    
//    let momentumLevel: Int
//    @State var timer: Timer?
//    @State var frameIndex: Int = 0
//
//    
//    var body: some View {
//
//            
//                
//        GeometryReader { geometry in
//            let sizeRatio = fireSizeRatio(momentumLevel: momentumLevel)*0.95*0.85*0.85
//            if momentumLevel == 0 {
////                Image("fire6_frame1")
//                Image("fire0")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: geometry.size.width*sizeRatio, height: geometry.size.height*sizeRatio)
//                    .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                    .opacity(0.8)
////                    .opacity(0.4)
//
//            } else {
//                let fps = fps(momentumLevel: momentumLevel)
//                let frameCount = frameCount(momentumLevel: momentumLevel)
//                let sizeRatio = fireSizeRatio(momentumLevel: momentumLevel)
//                
//                Image("fire\(momentumLevel)_frame\(frameIndex+1)")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: geometry.size.width*sizeRatio, height: geometry.size.height*sizeRatio)
//                //                .blur(radius: 1)
//                    .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                    .onAppear() {
//                        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / fps, repeats: true) { _ in
//                            frameIndex = (frameIndex + 1) % frameCount
//                        }
//                        RunLoop.current.add(timer!, forMode: .common)
//                        
//                    }
//                    .onDisappear() {
//                        timer?.invalidate()
//                        timer = nil
//                        
//                    }
//            }
//                
//        }
//
//    }
//}


// 커질수록 점점 느리게 불타오르도록
//struct FireView: View {
//    
//    var momentumLevel: Int
//    
//    var body: some View {
//        GeometryReader { geometry in
//            
//            let geoWidth: CGFloat = geometry.size.width
//            let geoHeight: CGFloat = geometry.size.height
//            
//            switch momentumLevel {
//            case 0: Spacer()
//            case 1: Fire1()
//            case 2: Fire2()
//            case 3: Fire3()
//            case 4: Fire4()
//            case 5: Fire5()
//            case 6: Fire6()
//            case 7: Fire7()
//            case 8: Fire8()
//            case 9: Fire9()
//            case 10: Fire10()
//            case 11: Fire1()
//            case 12: Fire1()
//            case 13: Fire1()
//            case 14: Fire1()
//            case 15: Fire1()
//            case 16: Fire1()
//            case 17: Fire1()
//            case 18: Fire1()
//            case 19: Fire1()
//            case 20: Fire1()
//            case 21: Fire1()
//            case 22: Fire1()
//            case 23: Fire1()
//            case 24: Fire1()
//            case 25: Fire1()
//            case 26: Fire1()
//            case 27: Fire1()
//            case 28: Fire1()
//            case 29: Fire1()
//            case 30: Fire1()
//            case 31: Fire1()
//            case 32: Fire1()
//            case 33: Fire1()
//            case 34: Fire1()
//
//
//                
//            default: Spacer()
//            }
//        }
//    }
//}


//struct Fire1: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        
//        let ratio: CGFloat = 0.95*0.85*0.85
//        
//        GeometryReader { geometry in
//            Image("fire1_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
////                .blur(radius: 1)
//            .position(x:geometry.size.width/2, y:geometry.size.height/2)
//            .onAppear() {
//                timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 12, repeats: true) { _ in
//                    frameIndex = (frameIndex + 1) % 9
//                }
//                RunLoop.current.add(timer!, forMode: .common)
//
//            }
//            .onDisappear() {
//                timer?.invalidate()
//                timer = nil
//            
//            }
//                
//        }
//
//    }
//}
//
//struct Fire2: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        
//        let ratio: CGFloat = 0.95*0.85*0.85
//        
//        GeometryReader { geometry in
//            Image("fire2_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 12, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 9
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
//
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//
//struct Fire3: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        
//        let ratio: CGFloat = 0.95*0.85*0.85
//
//        
//        GeometryReader { geometry in
//            Image("fire3_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    Timer.scheduledTimer(withTimeInterval: 1.0 / 12, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 9
//                    }
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//
//struct Fire4: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        
//        let ratio: CGFloat = 0.95*0.85*0.85
//
//        GeometryReader { geometry in
//            Image("fire4_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 15, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 9
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
//
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//
//struct Fire5: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        
//        let ratio: CGFloat = 0.95*0.85*0.85
//
//        
//        GeometryReader { geometry in
//            Image("fire5_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / size3fps, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 24
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
//
//                    
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//
//
//struct Fire6: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//    
//    var body: some View {
//        
//        let ratio: CGFloat = 0.95*0.85*0.85
////        var timer: Timer?
//        
//        GeometryReader { geometry in
//        
//            Image("fire6_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
////                .blur(radius: 0.3)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)                
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 6
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
////                    withAnimation(Animation.linear(duration: 1.0 / 20).repeatForever(autoreverses: false)) {
////                        frameIndex = (frameIndex + 1) % 6
////                    }
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//
//struct Fire7: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        
//        let ratio: CGFloat = 0.95*0.85
//
//        
//        GeometryReader { geometry in
//            Image("fire7_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 25, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 6
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
//
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//
//struct Fire8: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        
//        let ratio: CGFloat = size4Ratio
//        
//        GeometryReader { geometry in
//            Image("fire8_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / size4fps, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 24
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
//
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//struct Fire9: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        let ratio: CGFloat = 0.95
//        
//        GeometryReader { geometry in
//            Image("fire9_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 40, repeats: true) { _ in
//                            frameIndex = (frameIndex + 1) % 3
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
//
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//struct Fire10: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//
//    
//    var body: some View {
//        GeometryReader { geometry in
//            Image("fire10_frame\(frameIndex+1)")
//                .resizable()
//                .scaledToFit()
//                .frame(width: geometry.size.width, height: geometry.size.height)
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 4
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
//
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//
//
//struct Fire6_forContentViewBackground: View {
//    
//    @State var frameIndex: Int = 0
//    @State var timer: Timer?
//    
//    var body: some View {
//        
////        var timer: Timer?
//        
//        GeometryReader { geometry in
//        
//            Image("fire6_frame\(frameIndex+1)")
//                .resizable()
////                .scaledToFill()
//                .frame(width: geometry.size.width, height: geometry.size.height)
////                .blur(radius: 0.3)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 15, repeats: true) { _ in
//                        frameIndex = (frameIndex + 1) % 6
//                    }
//                    RunLoop.current.add(timer!, forMode: .common)
////                    withAnimation(Animation.linear(duration: 1.0 / 20).repeatForever(autoreverses: false)) {
////                        frameIndex = (frameIndex + 1) % 6
////                    }
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                
//                }
//        }
//
//    }
//}
//
//struct FireBackgroundView: View {
//    
//    @State var timer: Timer?
//
//
//    @State var num: Int = 0
//    @State var num_str: String = "00"
//
//    var body: some View {
//    
//        GeometryReader { geometry in
//            
//            Image("00000\(num_str)")
//                .resizable()
//                .frame(width: geometry.size.width, height: geometry.size.height)
//                .position(x:geometry.size.width/2, y:geometry.size.height/2)
//                .onAppear() {
//                    
//                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0 , repeats: true) { _ in
//                        num = (num + 1) % 96
//                        if num < 10 {
//                            num_str = "0" + String(num)
//                        }
//                        else {
//                            num_str = String(num)
//                        }
//                    }
//                    
//                    RunLoop.current.add(timer!, forMode: .common)
//                    
//                    
//                    
//                }
//                .onDisappear() {
//                    timer?.invalidate()
//                    timer = nil
//                    
//                }
//            
//        }
//    }
//}
//
