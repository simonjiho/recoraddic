//
//  buttonsView.swift
//  recoraddic
//
//  Created by 김지호 on 11/26/23.
//

import Foundation
import SwiftUI

// button은 항상 layout보다 선행되어야 함.

struct BackButton: ViewModifier {

    @Binding var viewToggler: Bool
    
    func body(content:Content) -> some View {
        VStack {
            Spacer().frame(height: 15)
            HStack {
                Button(action: {viewToggler.toggle()}) {
                    Image(systemName: "arrowshape.backward.fill")
                }
                Spacer()
            }
            content

        }
            
    }
}



extension View {
    
    

    func backButton(
        viewToggler: Binding<Bool>
        ) -> some View {
        self.modifier(recoraddic.BackButton(viewToggler: viewToggler))
    }
}
