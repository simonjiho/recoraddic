//
//  purposeTags.swift
//  recoraddic
//
//  Created by 김지호 on 1/1/24.
//

import Foundation
import SwiftUI
import SwiftData

//struct PurposeOfTodoView_circle_checkMark: View {
//    
//    @Environment(\.colorScheme) var colorScheme
//
//    
//    @Bindable var dailyRecordsViewModel: DailyRecordsViewModel
//    
//    @State var popUp_changePurpose: Bool = false
//    var todoId: String
//    var parentWidth: CGFloat
//    var parentHeight: CGFloat
//    
//    var body: some View {
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
//        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
//        
//
//            Image(systemName:"checkmark")
//                .background(PurposeInCircle(purposes:todo.purposes))
//                .foregroundStyle(reversedColorSchemeColor.opacity(todo.purposes.count == 0 ? 1.0 : 0.0))
//            .onTapGesture {
//                popUp_changePurpose.toggle()
//            }
//            .popover(isPresented: $popUp_changePurpose) {
//                ChoosePurposeView_todo(todoId: todoId)
//                    .frame(width:parentWidth*0.8, height: parentWidth*0.8) // 13개 4*4 grid
//                    .presentationCompactAdaptation(.popover)
//                
//            }
//                    
//    }
//}


struct PurposeOfMountainView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query var mountains: [Mountain_fb]
    
    @State var popUp_changePurpose: Bool = false
    var mountain: MileStone
    var parentWidth: CGFloat
    var parentHeight: CGFloat
//    var isAlmostLast: Bool = false
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                let geoWidth: CGFloat = geometry.size.width
                let geoHeight: CGFloat = geometry.size.height
                
                Button(action:{
                    if geometry.frame(in: .global).minY > UIScreen.main.bounds.height*0.5 {
                        scrollProxy.scrollTo(mountain.name, anchor: .center)
                    }
//                    scrollProxy.scrollTo(mountain.name, anchor: isAlmostLast ? .top : .center)
                    popUp_changePurpose.toggle()
                }) {
                    Group {
                        if mountain.recentPurpose.isEmpty {
                            Color.white.opacity(0.01)
                                .frame(width: geoWidth/2.5, height:geoHeight/2.5)
                                .overlay(
                                    Image(systemName:"questionmark.circle")
                                        .resizable()
                                        .frame(width:geoWidth/2.5, height:geoHeight/2.5)
                                        .foregroundStyle(reversedColorSchemeColor)
                                )
                            // MARK: buttonStyle(.plain) 이 조건문에서는 작동 안해서 이렇게 함
                        }
                        else {
                            PurposeInCircle(purposes:mountain.recentPurpose)
                                .frame(width: geoWidth/2.5, height:geoHeight/2.5)
                        }
                    }
                    .padding(.init(top: 7.5, leading: 7.5, bottom: 0, trailing: 0))
                    .frame(width:geoWidth, height:geoHeight, alignment: .topLeading)
                    
                    
                    
                }
                .frame(width:geoWidth, height:geoHeight)
                .popover(isPresented: $popUp_changePurpose) {
                    ChoosePurposeView_Mountain(mountain: mountain)
                        .frame(width:parentWidth*0.8, height: parentWidth*0.8) // 13개 4*4 grid
                        .presentationCompactAdaptation(.popover)
                    
                }
                .id(mountain.name)
            }
            
            
            
        }
    }
}

struct PurposeOfMountainView_redesigned: View {
    
    @Environment(\.colorScheme) var colorScheme

    @Bindable var mountainsViewModel: MountainsViewModel
    
    @State var popUp_changePurpose: Bool = false
    var mountain: Mountain_fb

//    var isAlmostLast: Bool = false
    
    var body: some View {
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
//        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                let geoWidth: CGFloat = geometry.size.width
                let geoHeight: CGFloat = geometry.size.height
                
                Button(action:{
                    if geometry.frame(in: .global).minY > UIScreen.main.bounds.height*0.5 {
                        scrollProxy.scrollTo(mountain.name, anchor: .center)
                    }
//                    scrollProxy.scrollTo(mountain.name, anchor: isAlmostLast ? .top : .center)
                    popUp_changePurpose.toggle()
                }) {
                    Group {
                        if mountain.recentPurpose.isEmpty {
                            Color.white.opacity(0.01)
                                .frame(width: geoWidth/2.5, height:geoHeight/2.5)
                                .overlay(
                                    Image(systemName:"questionmark.circle")
                                        .resizable()
                                        .frame(width:geoWidth/2.5, height:geoHeight/2.5)
                                        .foregroundStyle(.black)
                                )
                            // MARK: buttonStyle(.plain) 이 조건문에서는 작동 안해서 이렇게 함
                        }
                        else {
                            ZStack {
                                PurposeInCircle(purposes:mountain.recentPurpose)
                                    .frame(width: geoWidth/2.5, height:geoHeight/2.5)
                                Circle()
                                    .stroke(getTierColorOf(tier:mountain.tier))
//                                    .stroke(getDarkTierColorOf(tier:mountain.tier))

                            }
                            .frame(width: geoWidth/2.5, height:geoHeight/2.5)

                        }
                    }
                    .frame(width:geoWidth, height:geoHeight)
                    
                    
                }
                .frame(width:geoWidth, height:geoHeight)
                .popover(isPresented: $popUp_changePurpose) {
                    ChoosePurposeView_Mountain(mountain: mountain)
                        .frame(width:UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width*0.8) // 13개 4*4 grid

                        .presentationCompactAdaptation(.popover)
                    
                }
                .id(mountain.name)
            }
            
            
            
        }
    }
}


struct PurposeOfTodoView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query var todos_preset: [Todo_preset]
    
    @State var popUp_changePurpose: Bool = false
    var todo: Todo_fb
    var parentWidth: CGFloat
    var parentHeight: CGFloat
    
    var body: some View {
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let geoHeight: CGFloat = geometry.size.height
            let tagSize = min(geoWidth*0.8,geoHeight*0.3)

            
            Group {
                Group {
                    // purpose 0개일 때
                    if todo.purposes.count == 0 {
                        Image(systemName:"questionmark.square")
                            .resizable()
                            .frame(width:tagSize, height:tagSize)
                            .foregroundStyle(reversedColorSchemeColor)
                    }
                    else {
                        PurposeTagsView_vertical(purposes:todo.purposes)
                            .frame(width: geoWidth, height:geoHeight)
                    }
                    
                }
                .frame(width:geoWidth, height:geoHeight)
                .onTapGesture {
                    popUp_changePurpose.toggle()
                }
                
                //                                    .popover(isPresented: $popUp_changePurpose) {
                .popover(isPresented: $popUp_changePurpose) {
                    ChoosePurposeView_todo(todo: todo)
                        .frame(width:parentWidth*0.8, height: parentWidth*0.8) // 15개 4*4 grid
                        .presentationCompactAdaptation(.popover)
                        .onDisappear() {
                            if let todo_preset = todos_preset.first(where:{$0.content == todo.content}) {
                                todo_preset.purposes = todo.purposes
                            }
                        }
                    
                }
            }
            
        }
    }
}

struct ChoosePurposeView_Mountain: View {

    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var mountainsViewModel: MountainsViewModel
    
    var mountain: Mountain_fb
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let gridSize = geoWidth/4
            let tagSize = gridSize*0.8
            

            LazyVGrid(columns: [GridItem(.adaptive(minimum: tagSize))],spacing: tagSize*0.2) {
                
                ForEach(recoraddic.defaultPurposes, id:\.self) { purpose in
                    VStack(spacing:3.0) {
                        
                        PurposeTagView(purpose: purpose)
                            .frame(width: tagSize*0.65, height: tagSize*0.65)
                            .onTapGesture {
                                if mountain.recentPurpose.contains(purpose) { mountain.recentPurpose.remove(purpose)}
                                else if mountain.recentPurpose.count < 3 {
                                    mountain.recentPurpose.insert(purpose)
                                }
                                
                            }
                        Text(DefaultPurpose.inKorean(purpose))
                            .font(.caption)
                            .padding(.horizontal,2)
                        //                                .frame(width: geometry.size.width*0.3)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(mountain.recentPurpose.contains(purpose) ? colorSchemeColor : reversedColorSchemeColor)
                        
                        
                    } // Vstack
                    .frame(width: tagSize, height: tagSize)
                    .background(mountain.recentPurpose.contains(purpose) ? reversedColorSchemeColor : .gray.opacity(0.2))
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
    
    @Bindable var dailyRecordsViewModel: DailyRecordsViewModel
    
    var todoId: String
    
    var body: some View {
        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let gridSize = geoWidth/4
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



struct PurposeInCircle: View {
    
    var purposes: Set<String>
    
    var body: some View {
        
        let purposes_ordered: [String] = Array(purposes).sorted(by: { s1, s2 in
            return recoraddic.defaultPurposes.firstIndex(of: s1)! > recoraddic.defaultPurposes.firstIndex(of: s2)!
        })
        GeometryReader { geometry in
            ZStack {
                
                if purposes.count == 0 {
                    Spacer()
                }
                else if purposes.count == 1 {
                    Circle()
                        .fill(purposeColor(purpose: purposes_ordered[0]))
                }
                else if purposes.count == 2 {
                    Sector(startAngle: .degrees(0), endAngle: .degrees(180))
                        .fill(purposeColor(purpose: purposes_ordered[0]))
                    Sector(startAngle: .degrees(180), endAngle: .degrees(360))
                        .fill(purposeColor(purpose: purposes_ordered[1]))
                }
                else {
                    Sector(startAngle: .degrees(0), endAngle: .degrees(120))
                        .fill(purposeColor(purpose: purposes_ordered[0]))
                    
                    Sector(startAngle: .degrees(120), endAngle: .degrees(240))
                        .fill(purposeColor(purpose: purposes_ordered[1]))
                    
                    Sector(startAngle: .degrees(240), endAngle: .degrees(360))
                        .fill(purposeColor(purpose: purposes_ordered[2]))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct Sector: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        return path
    }
}


