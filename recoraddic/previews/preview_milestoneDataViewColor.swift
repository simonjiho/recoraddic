//
//  preview_ascentDataView.swift
//  recoraddic
//
//  Created by 김지호 on 2/5/25.
//

//struct AscentDataViewColorPreview: View {
//
//    @State var isAnimating: Bool = false
//    var tier: Int
//
//    var body: some View {
//
//
//
//        GeometryReader { geometry in
//
//            let geoWidth = geometry.size.width
//            let geoHeight = geometry.size.height
//
//
//            let a: Path = Path(CGPath(roundedRect: CGRect(x: 0, y: 0, width: geoWidth, height: geoHeight), cornerWidth: geoWidth/20, cornerHeight: geoHeight/20, transform: nil))
//
//
//            let percentage:CGFloat = 1.0
//            let brightness:CGFloat = percentage * 0.0
//
//
//            let gradientColors = getGradientColorsOf(tier: tier, type:0)
//            let _: [Color] = {
//                var newGradient: [Color] = []
//                for idx in 0...(gradientColors.count - 1) {
//                    if idx % 2 == 0 {
//                        newGradient.append(gradientColors[idx].adjust(brightness: brightness))
//                    }
//                    else {
//                        newGradient.append(gradientColors[idx].adjust(brightness: brightness*0.5))
//                    }
//                }
//                return newGradient
//            }()
//
//
//
//
//            ZStack {
//
//                ZStack {
//                    Rectangle()
//                        .fill(
//                            LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
//                        )
//                        .frame(width:geoWidth, height:geoHeight)
//                        .offset(x: (CGFloat(0) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth, y:0)
//                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), minutes: isAnimating)
//
//                    Rectangle()
//                        .fill(
//                            LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
//                        )
//                        .frame(width:geoWidth, height:geoHeight)
//                        .offset(x: (CGFloat(1) - (self.isAnimating ? 0.0 : 1.0)) * geoWidth, y:0)
//                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), minutes: isAnimating)
//                }
//                .frame(width:geoWidth, height:geoHeight)
//                .mask{a}
//                .onAppear() {
//                    isAnimating = true
//                }
//
//
//
//            }
//
//
//
//
//
//        }
//    }
//}

//#Preview(body: {
//    VStack {
//        MountainCheckBoxColorPreview(tier: 0)
//            .frame(width:300, height: 45)
//        MountainCheckBoxColorPreview(tier: 5)
//            .frame(width:300, height: 45)
//        MountainCheckBoxColorPreview(tier: 10)
//            .frame(width:300, height: 45)
//        MountainCheckBoxColorPreview(tier: 15)
//            .frame(width:300, height: 45)
//        MountainCheckBoxColorPreview(tier: 20)
//            .frame(width:300, height: 45)
//        MountainCheckBoxColorPreview(tier: 25)
//            .frame(width:300, height: 45)
//        MountainCheckBoxColorPreview(tier: 30)
//            .frame(width:300, height: 45)
//        MountainCheckBoxColorPreview(tier: 35)
//            .frame(width:300, height: 45)
//        MountainCheckBoxColorPreview(tier: 40)
//            .frame(width:300, height: 45)
//
//    }
//
//})
