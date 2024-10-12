//
//  PopupViewLayout.swift
//  recoraddic
//
//  Created by 김지호 on 11/24/23.
//

import Foundation
import SwiftUI

// backButton, xButton, yesOrNO button 들어간 뷰 따로 만들기 (popupLayout에서 뒤로 버튼 분리)

struct PopupViewLayout_fullSize: ViewModifier {
//    typealias Body = <#type#>
    var width: CGFloat
    var height: CGFloat
    
    func body(content:Content) -> some View {

        content
            .frame(width: width*0.8, height: height*0.9)
    //                .position(.zero)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: height*0.02)
            .shadow(radius: height*0.02)

            
    }
}


struct PopupViewLayout_smallSize: ViewModifier {
//    typealias Body = <#type#>
    var width: CGFloat
    var height: CGFloat
    
    func body(content:Content) -> some View {

        content
            .frame(width: width*0.5, height: height*0.2)
    //                .position(.zero)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: height*0.02)
            .shadow(radius: height*0.02)

            
    }
}

struct PopupViewLayout_bigSize: ViewModifier {
//    typealias Body = <#type#>
    var width: CGFloat
    var height: CGFloat
    
    func body(content:Content) -> some View {

        content
            .frame(width: width*0.7, height: height*0.7)
    //                .position(.zero)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: height*0.02)
            .shadow(radius: height*0.02)

            
    }
}

struct PopupViewLayout_middleSize: ViewModifier {
//    typealias Body = <#type#>
    var width: CGFloat
    var height: CGFloat
    
    func body(content:Content) -> some View {

        content
            .frame(width: width*0.6, height: height*0.4)
    //                .position(.zero)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: height*0.02)
            .shadow(radius: height*0.02)

            
    }
}

struct PopupViewLayout: ViewModifier {
//    typealias Body = <#type#>
    var width: CGFloat
    var height: CGFloat
    var color: Color
    
    func body(content:Content) -> some View {

        content
            .padding(10)
            .frame(width: width, height: height)
    //                .position(.zero)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: height*0.01)
            .shadow(radius: height*0.01)

            
    }
}

struct PopupViewLayout_noSize: ViewModifier {
//    var color: Color
    
    func body(content:Content) -> some View {

        content
            .padding(10)
            .background()
//            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 1)
            .shadow(radius: 1)

            
    }
}




extension View {
    
    
    func popUpViewLayout_fullSize(
        width:CGFloat,
        height:CGFloat
        ) -> some View {
        self.modifier(recoraddic.PopupViewLayout_fullSize(width: width, height: height))
    }
    
    func popUpViewLayout_smallSize(
        width:CGFloat,
        height:CGFloat
        ) -> some View {
        self.modifier(recoraddic.PopupViewLayout_smallSize(width: width, height: height))
    }
    
    func popUpViewLayout_middleSize(
        width:CGFloat,
        height:CGFloat
        ) -> some View {
        self.modifier(recoraddic.PopupViewLayout_middleSize(width: width, height: height))
    }
    
    func popUpViewLayout_bigSize(
        width:CGFloat,
        height:CGFloat
        ) -> some View {
        self.modifier(recoraddic.PopupViewLayout_bigSize(width: width, height: height))
    }
    
    func popUpViewLayout(
        width:CGFloat,
        height:CGFloat,
        color: Color
        ) -> some View {
            self.modifier(recoraddic.PopupViewLayout(width: width, height: height, color: color))
    }
    
    func popUpViewLayout(
//        color: Color
        ) -> some View {
            self.modifier(recoraddic.PopupViewLayout_noSize())
//            self.modifier(recoraddic.PopupViewLayout_noSize(color: color))
    }
}
