//
//  IntroView.swift
//  recoraddic
//
//  Created by 김지호 on 2023/09/23.
//

import Foundation
//
//  Intro.swift
//  recoraddic
//
//  Created by 김지호 on 2023/09/23.
//

import Foundation
import SwiftUI


struct IntroView: View {
    @Environment(\.modelContext) private var modelContext
    var currentRecord: Record!
    
    @Binding var pageIndex: Int
    
    @State private var gap: Bool = true
    
    
    
    
    
    var body: some View {
        ZStack {
            
            Color.gray
                .frame(width: 400, height: 300)
            
            VStack {
                Spacer().disabled(false)
                if pageIndex == 0 {
                    Text("하루종일 고생했어요!")
                }
                
                else if pageIndex == 1  {
                    if gap {
                        Spacer()
                            .frame(width: 400, height: 400)
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        self.gap = false
                                    }
                                }
                            }

                    }
                    else {
                        Text("오늘도 기록돌멩이를 만들어봐요!")
                            .onDisappear() {
                                self.gap = true
                            }
                    }
                    

                }
                Spacer().disabled(false)

                
                
            }
        }

    }
    
    
}
