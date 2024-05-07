////
////  TextFieldForHour.swift
////  recoraddic
////
////  Created by 김지호 on 12/10/23.
////
//
//import Foundation
//import SwiftUI
//
//
//struct TextFieldForHour: View {
//    
//    @Environment(\.modelContext) var modelContext
//    
//    
//    @State var naturalPart: String = ""
//    @State var firstDecimalPart: String = ""
//    @State var naturalPart_Int: Int = 0
//    @State var firstDecimalPart_Int: Int = 0
//    
//    @Binding var value: Int
//    
//    
//    var body: some View {
//            HStack(spacing: 2) {
//                TextField("0", text: $naturalPart)
//                    .frame(width:30)
//                    .keyboardType(.numberPad)
//                    .onChange(of: naturalPart) { oldVal, newVal in
//                        let filtered = String(newVal.filter { "0123456789".contains($0) })
//                        if let num = Int(filtered) {
//                            if num*10 <= DataType.maximumUnitOf(dataType: DataType.HOUR) {
//                                naturalPart = filtered
//                                naturalPart_Int = num
//                            }
//                            else {
//                                print("exceeded maximum number")
//                                naturalPart = oldVal
//                                naturalPart_Int = Int(naturalPart)!
//
//                            }
//                        }
//                        else {
//                            print("error_naturalpart")
//                        }
//                    }
////                    .onReceive(naturalPart.publisher.collect()) {
////                        let filtered = String($0.filter { "0123456789".contains($0) })
////                        if let num = Int(filtered) {
////                            if num <= DataType.maximumUnitOf(dataType: DataType.HOUR) {
////                                naturalPart = filtered
////                                naturalPart_Int = num
////                            }
////                            else {
////                                print("exceeded maximum number")
////                                naturalPart = String(naturalPart.dropLast())
////                                naturalPart_Int = Int(naturalPart)!
////
////                            }
////                        }
////                        else {
////                            print("error_naturalpart")
////                        }
////
////                    }
//                    .multilineTextAlignment(.trailing)
//                    .onChange(of: naturalPart_Int) {
//                            value = naturalPart_Int*10 + firstDecimalPart_Int
//                    }                
//                Text(".")
//                TextField("0", text: $firstDecimalPart)
//                    .frame(width:30)
//                    .keyboardType(.numberPad) // numberPad => no possibility of non-int string
//                    .onReceive(firstDecimalPart.publisher.collect()) {
////                        if firstDecimalPart != filtered {
////                            firstDecimalPart = filtered
////                        }
//                        let filtered = String($0.filter { "0123456789".contains($0) })
//                        if let num = Int(filtered), num >= 1, num <= 10 {
//                            firstDecimalPart = filtered
//                            firstDecimalPart_Int = num
//                        } else {
//                            firstDecimalPart = String(filtered.dropFirst())
////                            firstDecimalPart_Int = Int(filtered.dropLast())
//                            print("checking Error: if filtered is nil or non-numeric string, it is the error that can not happen logically. filtered: \(filtered)")
//                        }
//                        
//                    }
//                    .onChange(of: firstDecimalPart_Int) {
//                            value = naturalPart_Int*10 + firstDecimalPart_Int
//                    }
//
//                
//            }
//            .frame(alignment: .trailing)
//            .shadow(radius: 1)
//
//
//    }
//}
//
//
