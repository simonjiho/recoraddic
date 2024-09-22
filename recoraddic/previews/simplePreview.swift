//
//  simplePreview.swift
//  recoraddic
//
//  Created by 김지호 on 9/28/24.
//
import SwiftUI

#Preview(body: {
    VStack(spacing:0.0) {
//        Color(uiColor: UIColor(Color.blue.adjust(saturation: -0.4, brightness: 0.3)))
        Color(red:2.0/255.0, green:0.0/255.0, blue: 125.0/255.0)

        HStack(spacing:0.0) {
            LinearGradient(colors: [
                .blue.adjust(saturation: 0.5, brightness: -0.5),.blue.adjust(saturation: 0.7, brightness: -0.9)
            ],startPoint: .top,endPoint: .bottom)
            LinearGradient(colors: [
                Color(red:0.0/255.0, green:0.0/255.0, blue: 125.0/255.0),
                Color(red:2.0/255.0, green:0.0/255.0, blue: 75.0/255.0),
                Color(red:0.0/255.0, green:0.0/255.0, blue: 25.0/255.0)
,
                
            ],startPoint: .top,endPoint: .bottom)
            
        }
    }
})
