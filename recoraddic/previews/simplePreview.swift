//
//  simplePreview.swift
//  recoraddic
//
//  Created by 김지호 on 9/28/24.
//
import SwiftUI

let groundColor1 = Color(red:0.0/255.0, green:65.0/255.0, blue: 0.0/255.0)
let groundColor2 = Color(red:0.0/255.0, green:25.0/255.0, blue: 0.0/255.0)
let groundColor3 = Color(red:210.0/255.0, green:255.0/255.0, blue: 150.0/255.0)
let groundColor4 = Color(red:245.0/255.0, green:255.0/255.0, blue: 220.0/255.0)
#Preview(body: {
    VStack {
        HStack {
            LinearGradient(colors: [
                Color(red:0.0/255.0, green:255.0/255.0, blue: 255.0/255.0),
                Color(red:155.0/255.0, green:255.0/255.0, blue: 255.0/255.0)
            ], startPoint: .top, endPoint: .bottom
            )
            .overlay(content: {Text("hello").opacity(0.5)})

            VStack(spacing:0.0) {
                LinearGradient(colors: [
                    Color(red:100.0/255.0, green:255.0/255.0, blue: 255.0/255.0),
                    Color(red:255.0/255.0, green:255.0/255.0, blue: 255.0/255.0)
                ], startPoint: .top, endPoint: .bottom
                )            .overlay(content: {Text("hello").opacity(0.5)})
                LinearGradient(colors: [
                    groundColor4,
                    groundColor3
                ], startPoint: .top, endPoint: .bottom
               )
            }

        }
        
        HStack {
            LinearGradient(colors: [
                Color(red:0.0/255.0, green:0.0/255.0, blue: 200.0/255.0),
                Color(red:0.0/255.0, green:0.0/255.0, blue: 100.0/255.0)
            ], startPoint: .top, endPoint: .bottom
            )            .overlay(content: {Text("hello").opacity(0.8)})

            VStack(spacing:0.0) {
                LinearGradient(colors: [
                    Color(red:0.0/255.0, green:0.0/255.0, blue: 100.0/255.0),
                    Color(red:0.0/255.0, green:0.0/255.0, blue: 0.0/255.0)
                ], startPoint: .top, endPoint: .bottom
                )            .overlay(content: {Text("hello").opacity(0.8)})
                LinearGradient(colors: [
                    groundColor2,
                    groundColor1
                ], startPoint: .top, endPoint: .bottom
               )
            }

        }
    }
})
