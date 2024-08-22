//
//  MainView_Memo.swift
//  recoraddic
//
//  Created by 김지호 on 8/17/24.
//

import Foundation
import SwiftUI
import SwiftData

struct MainView_Memo:View {
    
    @Environment(\.modelContext) var modelContext
    
    @State var profile: Profile
    
    @FocusState var isEditing: Bool
    
    var body: some View {
//        MarkdownEditor(text: $profile.memo)
        GeometryReader { geometry in
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            let topBarTopPadding = geoHeight*0.035
            let topBarSize = geoHeight*0.05
            let topBarBottomPadding = geoHeight*0.005
            VStack(spacing:0.0) {
                
                HStack {
                    if isEditing {
                        Button("완료"){
                            isEditing = false
                        }
                        .disabled(!isEditing)
                        .opacity(isEditing ? 1.0 : 0.0)
                    }
                    else {
                        Image(systemName: "note.text")
                    }
                }
                .padding(isEditing ? .trailing : .horizontal)
                .frame(width: UIScreen.main.bounds.width,height:topBarSize,alignment: isEditing ? .trailing : .center)
                .padding(.top,topBarTopPadding)
                .padding(.bottom,topBarBottomPadding)
                TextEditor(text: $profile.memo)
                    .padding()
                    .focused($isEditing)
                    .textEditorStyle(.plain)
//                    .background(.tertiary)
                    .overlay {
                        if profile.memo == "" {
                            Text("탭해서 간단히 메모해둘 내용을 적어보세요")
                                .opacity(0.5)
                            //                            .containerRelativeFrame([.vertical,.horizontal], alignment: .topLeading)
                            //                            .frame(alignment:.topLeading)
                        }
                    }
            }
            //        .padding(.horizontal,10)
            .frame(width: UIScreen.main.bounds.width, height: geoHeight)
            //        .background(.quaternary)
            //        .border(.red)
            
        }

            
            
    }
}


struct MarkdownEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let attributedString = try? NSAttributedString(markdown: text)
        uiView.attributedText = attributedString
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownEditor

        init(_ parent: MarkdownEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
