//
//  QuestThumbnail_reDesigned.swift
//  recoraddic
//
//  Created by 김지호 on 10/8/24.
//

import SwiftUI


#Preview(body: {
    VStack(alignment:.leading) {
        HStack(spacing:20) {
            QuestThumbnailView3(
                name: "testQuest1",
                tier: 14,
                data: 3000,
                dataType:DataType.hour,
                purposes:[DefaultPurpose.ach,DefaultPurpose.alt,DefaultPurpose.cmn],
                momentumLevel: 26
            )
            .frame(width:140, height:85)
            QuestThumbnailView3(
                name: "testQues223232425t",
                tier: 16,
                data: 3000,
                dataType:DataType.hour,
                purposes:[DefaultPurpose.ach,DefaultPurpose.alt,DefaultPurpose.cmn],
                momentumLevel: 10
            )
            
            .frame(width:140, height:85)
        }
        .frame(width:360)
        HStack(spacing:20) {
            QuestThumbnailView4(
                name: "testQuest",
                tier: 14,
                data: 3000,
                dataType:DataType.hour,
                purposes:[],
                momentumLevel: 6
            )
            .frame(width:140, height:85)
            QuestThumbnailView4(
                name: "testQuest",
                tier: 16,
                data: 3000,
                dataType:DataType.hour,
                purposes:[DefaultPurpose.ach,DefaultPurpose.alt,DefaultPurpose.cmn],
                momentumLevel:33
            )
            
            .frame(width:140, height:85)
            
        }
        .frame(width:360)
        
        QuestThumbnailView6(
            name: "testQuest",
            tier: 16,
            data: 3000,
            dataType:DataType.hour,
            purposes:[DefaultPurpose.ach,DefaultPurpose.alt,DefaultPurpose.cmn],
            momentumLevel: 6
        )
        
        .frame(width:140, height:85)

        
//        .border(.red)
    }
})


struct QuestThumbnailView2: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    var name: String
    var tier: Int
    var data: Int
    var dataType: DataType
    var purposes: Set<String>
    var momentumLevel: Int

    
    var body: some View {
        
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)

        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            

            
            ZStack {
                QuestTierView(tier: tier, notUsedYet: data == 0)
                    .frame(width: geoWidth, height: geoHeight)
                HStack {
                    Group {
                        if purposes.isEmpty {
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
                            PurposeInCircle(purposes:purposes)
                                .frame(width: geoWidth/2.5, height:geoHeight/2.5)
                            
                        }
                    }
                    .frame(width:geoWidth*0.15, height:geoWidth*0.15)
                    
//                    .border(.red)
                    VStack {
                        Text("\(name)")
                            .foregroundStyle(getDarkTierColorOf(tier:tier))
                            .bold()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .padding(.bottom, geoHeight*0.05)
                        
                        //                                        Text(QuestRepresentingData.titleOf(representingData: quest.representingData))
                        
                        Text(name)
                            .foregroundStyle(getDarkTierColorOf(tier: tier))
                            .font(.caption)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                        
                        
                    }
                    .frame(width:geoWidth*0.6,alignment: .center)

                    FireView(momentumLevel: momentumLevel)
                        .frame(width: geoWidth*0.15, height: geoWidth*0.15, alignment: .trailing)
//                        .border(.red)
//                        .opacity(0.7)

                }
                .frame(width:geoWidth,height:geoHeight)
//                .border(.blue)
//                .onAppear() {
//                    print("\(quest.name): tier \(quest.tier)")
//                }
                
            }
        }
    }
}

struct QuestThumbnailView3: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    var name: String
    var tier: Int
    var data: Int
    var dataType: DataType
    var purposes: Set<String>
    var momentumLevel: Int

    
    var body: some View {
        
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)

        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            let badgeSize:CGFloat = geoHeight*0.45
            let textWidth:CGFloat = (geoWidth - badgeSize)*0.9
            
            ZStack {
                QuestTierView(tier: tier, notUsedYet: data == 0)
                    .frame(width: geoWidth, height: geoHeight)
                HStack(spacing: 0.0) {
                    VStack(spacing:0.0) {
                        FireView(momentumLevel: momentumLevel)
                            .frame(width: badgeSize, height: badgeSize, alignment: .trailing)
//                            .border(.blue)
                        Group {
                            if purposes.isEmpty {
                                Color.white.opacity(0.01)
                                    .frame(width: geoHeight*0.45, height:geoHeight/2.5)
                                    .overlay(
                                        Image(systemName:"questionmark.circle")
                                            .resizable()
                                            .frame(width:geoWidth/2.5, height:geoHeight/2.5)
                                            .foregroundStyle(reversedColorSchemeColor)
                                    )
                                // MARK: buttonStyle(.plain) 이 조건문에서는 작동 안해서 이렇게 함
                            }
                            else {
                                PurposeInCircle(purposes:purposes)
                                    .frame(width: geoHeight*0.2, height:geoHeight*0.2)
                                
                            }
                        }
                        .frame(width:geoHeight*0.45, height:geoHeight*0.45)
                        
                    }
                    .frame(width:badgeSize,height:geoHeight*0.9)
                    
                    
                    VStack {
                        Text("\(name)")
                            .foregroundStyle(getDarkTierColorOf(tier:tier))
                            .bold()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        
                        Text("누적 000h 00m")
                            .foregroundStyle(getDarkTierColorOf(tier: tier))
                            .font(.caption)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                        
                        
                    }
                    .frame(width:textWidth,alignment: .center)
//                    .border(.red)


//                        .border(.red)
//                        .opacity(0.7)

                }
                .frame(width:geoWidth,height:geoHeight)
//                .border(.blue)
//                .onAppear() {
//                    print("\(quest.name): tier \(quest.tier)")
//                }
                
            }
        }
    }
}


struct QuestThumbnailView4: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    var name: String
    var tier: Int
    var data: Int
    var dataType: DataType
    var purposes: Set<String>
    var momentumLevel: Int

    
    var body: some View {
        
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)

        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            let badgeSize:CGFloat = geoHeight*0.45
            let textWidth:CGFloat = (geoWidth - badgeSize)*0.9
            
            ZStack {
                QuestTierView(tier: tier, notUsedYet: data == 0)
                    .frame(width: geoWidth, height: geoHeight)
                
                Group {
                    if purposes.isEmpty {
                        Color.white.opacity(0.01)
                            .frame(width: geoWidth/10, height:geoWidth/10)
                            .overlay(
                                Image(systemName:"questionmark.circle")
                                    .resizable()
                                    .frame(width:geoWidth/10, height:geoWidth/10)
                                    .foregroundStyle(reversedColorSchemeColor)
                            )
                        // MARK: buttonStyle(.plain) 이 조건문에서는 작동 안해서 이렇게 함
                    }
                    else {
                        PurposeInCircle(purposes:purposes)
                            .frame(width: geoWidth*0.1, height:geoWidth*0.1)
                        
                    }
                }
                .padding(.init(top: 7.5, leading: 7.5, bottom: 0, trailing: 0))
//                .frame(width:geoHeight*0.45, height:geoHeight*0.45)
                .frame(width:geoWidth/4, height:geoWidth/4, alignment:.topLeading)
                .position(CGPoint(x: geoWidth/8, y: geoWidth/8))
                

                    VStack(spacing:0.0) {
                        FireView(momentumLevel: momentumLevel)
                            .frame(width: badgeSize, height: badgeSize, alignment: .trailing)

                        Text("\(name)")
                            .foregroundStyle(getDarkTierColorOf(tier:tier))
                            .bold()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        
                        
                    }
                    .frame(width:textWidth,alignment: .center)
//                    .border(.red)


//                        .border(.red)
//                        .opacity(0.7)


//                .border(.blue)
//                .onAppear() {
//                    print("\(quest.name): tier \(quest.tier)")
//                }
                
            }
        }
    }
}


struct QuestThumbnailView5: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    var name: String
    var tier: Int
    var data: Int
    var dataType: DataType
    var purposes: Set<String>
    var momentumLevel: Int

    
    var body: some View {
        
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)

        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            let purposeTagSize:CGFloat = geoHeight*0.3
            let badgeSize:CGFloat = geoHeight*0.5
//            let textWidth:CGFloat = (geoWidth - badgeSize)*0.9
            
            HStack {
                Group {
                    if purposes.isEmpty {
                        Color.white.opacity(0.01)
                            .frame(width: purposeTagSize, height:purposeTagSize)
                            .overlay(
                                Image(systemName:"questionmark.circle")
                                    .resizable()
                                    .frame(width:purposeTagSize, height:purposeTagSize)
                                    .foregroundStyle(reversedColorSchemeColor)
                            )
                        // MARK: buttonStyle(.plain) 이 조건문에서는 작동 안해서 이렇게 함
                    }
                    else {
                        ZStack {
                            PurposeInCircle(purposes:purposes)
                                .frame(width: purposeTagSize, height:purposeTagSize)
                            Circle()
                                .stroke(.black)
                                .frame(width: purposeTagSize, height:purposeTagSize)

                            
                        }
                    }
                }
                .frame(width:purposeTagSize, height:purposeTagSize)
                .opacity(0.8)
                ZStack {
                    QuestTierView(tier: tier, notUsedYet: data == 0)
                        .frame(width: badgeSize, height: badgeSize)
                    HStack(spacing:0.0) {
                        FireView(momentumLevel: momentumLevel)
                            .frame(width: badgeSize, height: badgeSize)
                    }
                    .frame(width: badgeSize)

                }
                Text("\(name)")
                    .foregroundStyle(getDarkTierColorOf(tier:tier))
                    .bold()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
//                    .border(.red)
                
            }
            .frame(width:geoWidth, alignment:.leading)
//            .border(.red)


        }
    }
}


struct QuestThumbnailView6: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    var name: String
    var tier: Int
    var data: Int
    var dataType: DataType
    var purposes: Set<String>
    var momentumLevel: Int

    
    var body: some View {
        
        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)

        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            let badgeSize:CGFloat = geoHeight*0.45
            let textWidth:CGFloat = (geoWidth - badgeSize)*0.9
            
            ZStack {
                QuestTierView(tier: tier, notUsedYet: data == 0)
                    .frame(width: geoWidth, height: geoHeight)
                HStack(spacing: 0.0) {
                        FireView(momentumLevel: momentumLevel)
                            .frame(width: badgeSize, height: badgeSize, alignment: .trailing)
//                            .border(.blue)
//                        .border(.blue)
                        
//                    .border(.red)
                    VStack {
                        Text("\(name)")
                            .foregroundStyle(getDarkTierColorOf(tier:tier))
                            .bold()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
//                            .padding(.bottom, geoHeight*0.05)
                        
                        //                                        Text(QuestRepresentingData.titleOf(representingData: quest.representingData))
                        
                        Text(name)
                            .foregroundStyle(getDarkTierColorOf(tier: tier))
                            .font(.caption)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                        
                        
                    }
                    .frame(width:textWidth,alignment: .center)
//                    .border(.red)


//                        .border(.red)
//                        .opacity(0.7)

                }
                .frame(width:geoWidth,height:geoHeight)
                
                Group {
                    if purposes.isEmpty {
                        Color.white.opacity(0.01)
                            .frame(width: geoHeight*0.45, height:geoHeight/2.5)
                            .overlay(
                                Image(systemName:"questionmark.circle")
                                    .resizable()
                                    .frame(width:geoWidth/2.5, height:geoHeight/2.5)
                                    .foregroundStyle(reversedColorSchemeColor)
                            )
                        // MARK: buttonStyle(.plain) 이 조건문에서는 작동 안해서 이렇게 함
                    }
                    else {
                        PurposeInCircle(purposes:purposes)
                            .frame(width: geoHeight*0.2, height:geoHeight*0.2)
                        
                    }
                }
                .padding(.init(top: 7.5, leading: 7.5, bottom: 0, trailing: 0))
//                .frame(width:geoHeight*0.45, height:geoHeight*0.45)
                .frame(width:geoWidth/4, height:geoWidth/4, alignment:.topLeading)
                .position(CGPoint(x: geoWidth/8, y: geoWidth/8))
                .opacity(0.8)//                .border(.blue)
//                .onAppear() {
//                    print("\(quest.name): tier \(quest.tier)")
//                }
                
            }
            .frame(width:geoWidth,height:geoHeight)

        }
    }
}
