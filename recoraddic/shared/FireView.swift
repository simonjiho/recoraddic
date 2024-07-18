//
//  fireViews.swift
//  recoraddic
//
//  Created by 김지호 on 2/9/24.
//

import SwiftUI


#Preview(body: {
    ScrollView {
        VStack {
            ForEach(1...10, id:\.self) { i in
                FireView(momentumLevel: i)
                    .frame(width:100, height:100)
            }
        }
        
    
    }
})

// 커질수록 점점 느리게 불타오르도록
struct FireView: View {
    
    var momentumLevel: Int
    
    var body: some View {
        GeometryReader { geometry in
            
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            
            switch momentumLevel {
            case 0: Spacer()
            case 1: Fire1()
            case 2: Fire2()
            case 3: Fire3()
            case 4: Fire4()
            case 5: Fire5()
            case 6: Fire6()
            case 7: Fire7()
            case 8: Fire8()
            case 9: Fire9()
            case 10: Fire10()
            case 11: Fire1()
            case 12: Fire1()
            case 13: Fire1()
            case 14: Fire1()
            case 15: Fire1()
            case 16: Fire1()
            case 17: Fire1()
            case 18: Fire1()
            case 19: Fire1()
            case 20: Fire1()
            case 21: Fire1()
            case 22: Fire1()
            case 23: Fire1()
            case 24: Fire1()
            case 25: Fire1()
            case 26: Fire1()
            case 27: Fire1()
            case 28: Fire1()
            case 29: Fire1()
            case 30: Fire1()
            case 31: Fire1()
                
            default: Spacer()
            }
        }
    }
}


struct Fire1: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        
        let ratio: CGFloat = 0.95*0.85*0.85
        
        GeometryReader { geometry in
            Image("fire1_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .blur(radius: 1)
            .position(x:geometry.size.width/2, y:geometry.size.height/2)
            .onAppear() {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 12, repeats: true) { _ in
                    frameIndex = (frameIndex + 1) % 9
                }
                RunLoop.current.add(timer!, forMode: .common)

            }
            .onDisappear() {
                timer?.invalidate()
                timer = nil
            
            }
                
        }

    }
}

struct Fire2: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        
        let ratio: CGFloat = 0.95*0.85*0.85
        
        GeometryReader { geometry in
            Image("fire2_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 12, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 9
                    }
                    RunLoop.current.add(timer!, forMode: .common)

                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}

struct Fire3: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        
        let ratio: CGFloat = 0.95*0.85*0.85

        
        GeometryReader { geometry in
            Image("fire3_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    Timer.scheduledTimer(withTimeInterval: 1.0 / 12, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 9
                    }
                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}

struct Fire4: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        
        let ratio: CGFloat = 0.95*0.85*0.85

        GeometryReader { geometry in
            Image("fire4_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 15, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 9
                    }
                    RunLoop.current.add(timer!, forMode: .common)

                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}

struct Fire5: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        
        let ratio: CGFloat = 0.95*0.85*0.85

        
        GeometryReader { geometry in
            Image("fire5_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 24
                    }
                    RunLoop.current.add(timer!, forMode: .common)

                    
                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}


struct Fire6: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?
    
    var body: some View {
        
        let ratio: CGFloat = 0.95*0.85*0.85
//        var timer: Timer?
        
        GeometryReader { geometry in
        
            Image("fire6_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
//                .blur(radius: 0.3)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)                
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 6
                    }
                    RunLoop.current.add(timer!, forMode: .common)
//                    withAnimation(Animation.linear(duration: 1.0 / 20).repeatForever(autoreverses: false)) {
//                        frameIndex = (frameIndex + 1) % 6
//                    }
                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}

struct Fire7: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        
        let ratio: CGFloat = 0.95*0.85

        
        GeometryReader { geometry in
            Image("fire7_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 25, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 6
                    }
                    RunLoop.current.add(timer!, forMode: .common)

                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}

struct Fire8: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        
        let ratio: CGFloat = 0.95*0.85
        
        GeometryReader { geometry in
            Image("fire8_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 40, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 6
                    }
                    RunLoop.current.add(timer!, forMode: .common)

                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}
struct Fire9: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        let ratio: CGFloat = 0.95
        
        GeometryReader { geometry in
            Image("fire9_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width*ratio, height: geometry.size.height*ratio)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 40, repeats: true) { _ in
                            frameIndex = (frameIndex + 1) % 3
                    }
                    RunLoop.current.add(timer!, forMode: .common)

                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}
struct Fire10: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?

    
    var body: some View {
        GeometryReader { geometry in
            Image("fire10_frame\(frameIndex+1)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 4
                    }
                    RunLoop.current.add(timer!, forMode: .common)

                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}


struct Fire6_forContentViewBackground: View {
    
    @State var frameIndex: Int = 0
    @State var timer: Timer?
    
    var body: some View {
        
//        var timer: Timer?
        
        GeometryReader { geometry in
        
            Image("fire6_frame\(frameIndex+1)")
                .resizable()
//                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
//                .blur(radius: 0.3)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 15, repeats: true) { _ in
                        frameIndex = (frameIndex + 1) % 6
                    }
                    RunLoop.current.add(timer!, forMode: .common)
//                    withAnimation(Animation.linear(duration: 1.0 / 20).repeatForever(autoreverses: false)) {
//                        frameIndex = (frameIndex + 1) % 6
//                    }
                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                
                }
        }

    }
}

struct FireBackgroundView: View {
    
    @State var timer: Timer?


    @State var num: Int = 0
    @State var num_str: String = "00"

    var body: some View {
    
        GeometryReader { geometry in
            
            Image("00000\(num_str)")
                .resizable()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x:geometry.size.width/2, y:geometry.size.height/2)
                .onAppear() {
                    
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0 , repeats: true) { _ in
                        num = (num + 1) % 96
                        if num < 10 {
                            num_str = "0" + String(num)
                        }
                        else {
                            num_str = String(num)
                        }
                    }
                    
                    RunLoop.current.add(timer!, forMode: .common)
                    
                    
                    
                }
                .onDisappear() {
                    timer?.invalidate()
                    timer = nil
                    
                }
            
        }
    }
}

