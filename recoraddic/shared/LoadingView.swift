//
//  LoadingView.swift
//  recoraddic
//
//  Created by 김지호 on 8/22/24.
//

import Foundation
import SwiftUI


struct LoadingView: View {
    var body: some View {
        
        ZStack {
            Image("loadingLogo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width/5)
        }
        .containerRelativeFrame([.horizontal,.vertical])
        .background(.quaternary)

    }
}


struct LoadingView_initialization: View {
//    @State var dot: String = ""
    var body: some View {
        VStack {
            Image("loadingLogo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width/5)
            HStack(spacing:10.0) {Text("로딩 중")
                ProgressView() // This is the loading circle
                    .progressViewStyle(CircularProgressViewStyle())
//                    .scaleEffect(1.5) // Adjust the scale of the loading circle
            }
            .padding(.top, 5)

        }
        .containerRelativeFrame([.horizontal,.vertical])
        .background(.quaternary)
    }
}

#Preview(body: {
    LoadingView_initialization()
        .containerRelativeFrame([.horizontal,.vertical])
})
