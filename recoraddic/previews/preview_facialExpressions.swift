//
//  previews.swift
//  recoraddic
//
//  Created by 김지호 on 8/28/24.
//

import Foundation
import SwiftUI

//#Preview {
//    VStack {
//        Text("\(facialExpression_tmp.count)/\(facialExpression_Middle.count)")
//        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 40))]) {
//            ForEach(facialExpression_tmp, id:\.self) { idx in
//                VStack(spacing:0.0) {
//                    Text("\(idx)")
//                        .font(.caption2)
//                    Image("facialExpression_\(idx)")
//                        .resizable()
//                        .frame(width:30, height: 30)
//                }
//            }
//
//        }
//        .padding(.bottom)
//
//
//        Text("\(facialExpression_Middle1.count)")
//        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 40))]) {
//            ForEach(facialExpression_Middle1, id:\.self) { idx in
//                VStack(spacing:0.0) {
//                    Text("\(idx)")
//                        .font(.caption2)
//                    Image("facialExpression_\(idx)")
//                        .resizable()
//                        .frame(width:30, height: 30)
//                }
//            }
//
//        }
//        .padding(.bottom)
//
//        Text("\(facialExpression_Middle2.count)")
//        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 40))]) {
//            ForEach(facialExpression_Middle2, id:\.self) { idx in
//                VStack(spacing:0.0) {
//                    Text("\(idx)")
//                        .font(.caption2)
//                    Image("facialExpression_\(idx)")
//                        .resizable()
//                        .frame(width:30, height: 30)
//                }
//            }
//
//        }
//        .padding(.bottom)
//
//
//        //        LazyVGrid(columns: [GridItem], content: <#T##() -> Content#>)
//
//        Text("\(Set(facialExpression_tmp).intersection(Set(facialExpression_Middle1)))")
//        Text("\(Set(facialExpression_tmp).intersection(Set(facialExpression_Middle2)))")
//        Text("\(Set(facialExpression_Middle1).intersection(Set(facialExpression_Middle2)))")
//
//        Text("\(Set(facialExpression_Middle) == Set(facialExpression_Middle1+facialExpression_Middle2+facialExpression_tmp))")
//        Text("\(Set(facialExpression_Middle).subtracting((Set(facialExpression_tmp))))")
//
//    }
//}
