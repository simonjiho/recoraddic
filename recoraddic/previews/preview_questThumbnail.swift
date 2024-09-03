//
//  preview_questThumbnail.swift
//  recoraddic
//
//  Created by 김지호 on 8/30/24.
//

import Foundation
import SwiftUI

struct QuestThumbnailView_forPreview: View {
    
    var name: String
    var tier: Int
    var momentumLevel: Int
    var cumulativeVal: String
    var unitNotation: String

    
    var body: some View {
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
//            let gridItemWidth = geoWidth
            
            ZStack {
                QuestTierView(tier: tier, notUsedYet: false)
                    .frame(width: geoWidth, height: geoHeight)
                FireView(momentumLevel: momentumLevel)
                //                                        Fire6()
                    .frame(width: geoWidth/1.5, height: geoHeight/1.5)
                    .position(x:geoWidth/2,y:geoHeight/2)
                //                                            .opacity(0.7)
                VStack {
                    Text("\(name)")
                        .foregroundStyle(.black)
                        .bold()
                        .minimumScaleFactor(0.3)
                        .lineLimit(2)
                        .padding(.bottom, geoHeight/10)
                    
                    //                                        Text(QuestRepresentingData.titleOf(representingData: quest.representingData))
                    
                    Text("\(cumulativeVal)\(unitNotation)")
                        .foregroundStyle(.black)
                        .bold()
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                    
                }
                .padding(10)
                .frame(width:geoWidth ,height: geoHeight, alignment: .center)
                .onAppear() {
//                    print("\(name): tier \(tier)")
                }
                
            }
        }
    }
}
//
#Preview(body: {
    HStack {
        VStack {
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 0,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 5,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 10,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 15,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 20,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)

        }
        VStack {
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 25,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 30,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 35,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)
            QuestThumbnailView_forPreview(
                name: "운동",
                tier: 40,
                momentumLevel: 7,
                cumulativeVal: "1000.0",
                unitNotation: "시간")
            .frame(width: 100, height: 100)

        }
        
    }

})
