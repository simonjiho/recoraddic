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
        .background(.quinary)

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
            HStack(spacing:10.0) {
                Text("로딩 중")
                ProgressView() // This is the loading circle
                    .progressViewStyle(CircularProgressViewStyle())
//                    .scaleEffect(1.5) // Adjust the scale of the loading circle
            }
            .padding(.top, 5)

        }
        .containerRelativeFrame([.horizontal,.vertical])
        .background(.quinary)
    }
}

struct LoadingView_fetch: View {
//    @State var dot: String = ""
    var retryCount: Int
    
    var body: some View {
        VStack {
            Image("loadingLogo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width/5)
            if retryCount < 3 {
                
                HStack(spacing:10.0) {
                    Text("업데이트 중")
                    ProgressView() // This is the loading circle
                        .progressViewStyle(CircularProgressViewStyle())
                    //                    .scaleEffect(1.5) // Adjust the scale of the loading circle
                }
                .padding(.top, 5)
            }
            else {
                Text("오류: 앱을 재시작 해주세요.")
            }

        }
        .containerRelativeFrame([.horizontal,.vertical])
        .background(.quinary)
    }
}

#Preview(body: {
//    LoadingView_initialization()
    LoadingView()
//        .containerRelativeFrame([.horizontal,.vertical])
})
