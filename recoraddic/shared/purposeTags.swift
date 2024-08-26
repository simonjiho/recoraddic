//
//  purposeTags.swift
//  recoraddic
//
//  Created by 김지호 on 1/1/24.
//

import Foundation
import SwiftUI


struct ChoosePurposeView_dailyQuest: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var dailyQuest: DailyQuest
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let gridSize = geoWidth/3
            let tagSize = gridSize*0.8
            

            LazyVGrid(columns: [GridItem(.adaptive(minimum: tagSize))],spacing: tagSize*0.2) {
                
                ForEach(recoraddic.defaultPurposes, id:\.self) { purpose in
                    VStack(spacing:3.0) {
                        
                        PurposeTagView(purpose: purpose)
                            .frame(width: tagSize*0.65, height: tagSize*0.65)
                            .onTapGesture {
                                if dailyQuest.purposes.contains(purpose) { dailyQuest.purposes.remove(purpose)}
                                else if dailyQuest.purposes.count < 3 {
                                    dailyQuest.purposes.insert(purpose)
                                }
                                
                            }
                        Text(DefaultPurpose.inKorean(purpose))
                            .font(.caption)
                            .padding(.horizontal,2)
                        //                                .frame(width: geometry.size.width*0.3)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(dailyQuest.purposes.contains(purpose) ? colorSchemeColor : reversedColorSchemeColor)
                        
                        
                    } // Vstack
                    .frame(width: tagSize, height: tagSize)
                    .background(dailyQuest.purposes.contains(purpose) ? reversedColorSchemeColor : .gray.opacity(0.2))
                    .clipShape(.buttonBorder)
                    
                    
                } // forEach
                
            } // scrollView
            .padding(10)
            .frame(width:geoWidth, height:geoHeight)
        }
    }
}

struct ChoosePurposeView_todo: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var todo: Todo
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let gridSize = geoWidth/3
            let tagSize = gridSize*0.8
            LazyVGrid(columns: [GridItem(.adaptive(minimum: tagSize))],spacing: tagSize*0.2) {

                ForEach(recoraddic.defaultPurposes, id:\.self) { purpose in
                    VStack(spacing:3.0) {
                        
                        PurposeTagView(purpose: purpose)
                            .frame(width: tagSize*0.65, height: tagSize*0.65)
                            .onTapGesture {
                                if todo.purposes.contains(purpose) { todo.purposes.remove(purpose)}
                                else if todo.purposes.count < 3 {
                                    todo.purposes.insert(purpose)
                                }
                                
                            }
                        Text(DefaultPurpose.inKorean(purpose))
                            .font(.caption)
                            .padding(.horizontal,2)
//                                .frame(width: geometry.size.width*0.3)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(todo.purposes.contains(purpose) ? colorSchemeColor : reversedColorSchemeColor)
                        
                        
                    } // Vstack
                    .frame(width: tagSize, height: tagSize)
                    .background(todo.purposes.contains(purpose) ? reversedColorSchemeColor : .gray.opacity(0.2))
                    .clipShape(.buttonBorder)
                    
                    
                } // forEach

            } // scrollView
            .padding(10)
            .frame(width:geoWidth, height:geoHeight)
//            .border(.red)
        }
    }
}



struct PurposeTagsView_leading: View {
    
    var purposes: Set<String>
    var purposes_sorted : [String]

    init(purposes: Set<String>) {
        self.purposes = purposes
        self.purposes_sorted = Array(purposes).sorted(by: { s1, s2 in
            return recoraddic.defaultPurposes.firstIndex(of: s1)! > recoraddic.defaultPurposes.firstIndex(of: s2)!
        })
    }
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let tagSize = min(geometry.size.width*0.3,geometry.size.height*0.8)

            HStack(spacing:geometry.size.width*0.05) {
                ForEach(purposes_sorted, id:\.self) { purpose in
                    PurposeTagView(purpose: purpose)
                        .frame(width: tagSize, height: tagSize)
                        .shadow(radius: 10.0)
                }

            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)


            
        }
    }
}



struct PurposeTagsView_center: View {
    
    var purposes: Set<String>
    var purposes_sorted : [String]

    init(purposes: Set<String>) {
        self.purposes = purposes
        self.purposes_sorted = Array(purposes).sorted(by: { s1, s2 in
            return recoraddic.defaultPurposes.firstIndex(of: s1)! > recoraddic.defaultPurposes.firstIndex(of: s2)!
        })
    }
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let tagSize = min(geometry.size.width*0.3,geometry.size.height*0.8)

            HStack(spacing:geometry.size.width*0.05) {
                ForEach(purposes_sorted, id:\.self) { purpose in
                    PurposeTagView(purpose: purpose)
                        .frame(width: tagSize, height: tagSize)
                        .shadow(radius: 10.0)
                }

            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)

            
        }
    }
}


struct PurposeTagsView_horizontal: View {
    
    var purposes: Set<String>
    var purposes_sorted : [String]
    let tagSize: CGFloat
    let spacing: CGFloat
    let totalWidth: CGFloat

    init(purposes: Set<String>, tagSize: CGFloat, spacing: CGFloat, totalWidth:CGFloat) {
        self.purposes = purposes
        self.purposes_sorted = Array(purposes).sorted(by: { s1, s2 in
            return recoraddic.defaultPurposes.firstIndex(of: s1)! > recoraddic.defaultPurposes.firstIndex(of: s2)!
        })
        self.tagSize = tagSize
        self.spacing = spacing
        self.totalWidth = totalWidth
    }
    
    
    var body: some View {
        
        GeometryReader { geometry in
            

            
            HStack(spacing:spacing) {
                ForEach(purposes_sorted, id:\.self) { purpose in
                    PurposeTagView(purpose: purpose)
                        .frame(width: tagSize, height: tagSize)
                        .shadow(radius: 10.0)
                }

            }
            .frame(width:totalWidth, height: geometry.size.height)

            
        }
    }
}





struct PurposeTagsView_vertical: View {
    
    var purposes: Set<String>
    var purposes_sorted : [String]

    init(purposes: Set<String>) {
        self.purposes = purposes
        self.purposes_sorted = Array(purposes).sorted(by: { s1, s2 in
            return recoraddic.defaultPurposes.firstIndex(of: s1)! > recoraddic.defaultPurposes.firstIndex(of: s2)!
        })
    }
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let tagSize = min(geometry.size.width*0.8,geometry.size.height*0.3)

            VStack(spacing:geometry.size.height*0.05) {
                ForEach(purposes_sorted, id:\.self) { purpose in
                    PurposeTagView(purpose: purpose)
                        .frame(width: tagSize, height: tagSize)
                        .shadow(radius: 10.0)
                }

            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)

            
        }
    }
}



struct PurposeTagView: View {
    
    var purpose: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
//                Circle()
//                    .frame(width: geometry.size.width, height: geometry.size.height)
//                    .foregroundStyle(recoraddic.defaultPurposes_per.contains(purpose) ? .green.adjust(saturation: 1, brightness: 0.5): .brown)
                Image("\(purpose)")
                    .resizable()
//                    .scaledToFill()
                    .frame(width: geometry.size.width*1.3, height: geometry.size.height*1.3)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

//struct ChoosePurposeView_Preview: View {
//    @State var chosenPurposes: Set<String> = Set()
//
//    var body: some View {
//        ChoosePurposeView(chosenPurposes: $chosenPurposes)
//    }
//}


//#Preview(body: {
////    ChoosePurposeView_Preview()
//    ChoosePurposeView(chosenPurposes: .constant(Set<String>()))
//        .frame(width:300, height:500)
//})
