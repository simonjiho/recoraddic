//
//  AddDiaryView.swift
//  recoraddic
//
//  Created by 김지호 on 12/17/23.
//

import Foundation
import SwiftUI
import SwiftData
import PhotosUI

struct AddDiaryView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    
    var selectedDailyRecord: DailyRecord
    
    @State var diaryText: String = ""
        
    @Binding var popUp_addDiary: Bool
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State var selectedImageData: Data? = nil

    @State var keyboardAppeared: Bool = false
    
    
    var body: some View {
        
//        let colorSchemeColor: Color = getColorSchemeColor(colorScheme)
//        let reversedColorSchemeColor: Color = getReversedColorSchemeColor(colorScheme)
        let shadowColor: Color = getShadowColor(colorScheme)
        
        GeometryReader { geometry in
            
            let geoWidth = geometry.size.width
            let geoHeight = geometry.size.height
            
            let imageWidth = geoWidth
            let imageHeight = keyboardAppeared ? geoHeight*0.07 : geoHeight*0.2
            let textBoxWidth = geometry.size.width*0.9
        
            let textBoxHeight = (keyboardAppeared ? geometry.size.height*0.5 : geometry.size.height*0.8) - ( selectedImageData == nil ? 0.0:imageHeight)
            let imageTopPointPadding = keyboardAppeared ? geometry.size.height*0.01 : geometry.size.height*0.03

            
            let spacingBetweenImageAndTextBox = selectedImageData != nil ? 15.0 : 0.0
            let spacingBetweenTextBoxAndPhotoPicker = 5.0

            
            ZStack {
                
                
                VStack {

                    
                    Spacer()
                        .frame(width:geometry.size.width, height: imageTopPointPadding)
//                        .border(.green)
                    

                    
                        if selectedImageData != nil {
                            ZStack {
                                Image(uiImage: UIImage(data: selectedImageData!)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: imageHeight)
                                Button(action:{
                                    selectedItem = nil
                                    selectedImageData = nil
                                }) {
                                    Image(systemName: "x.circle")
                                }
                                .frame(width: imageWidth*0.9, height: imageHeight, alignment: .topTrailing)
                            }
                            .frame(width: imageWidth, height: imageHeight)
//                            .border(.gray)                            
                            .padding(.bottom, spacingBetweenImageAndTextBox)


                            
                            
                        }
                        Spacer()
                            .frame(width: textBoxWidth, height: textBoxHeight, alignment: .top)
                            .background(.red)
//                            .shadow(radius: 5)
                            .padding(.bottom, spacingBetweenTextBoxAndPhotoPicker)

                    
                    
                    
                    HStack {
                        
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ){
                            Text("사진선택")
                                .frame(width: geometry.size.width*0.45, alignment: .leading)

                        }
                        .onChange(of: selectedItem) {
                            Task {
                                // Retrieve selected asset in the form of Data
                                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    // Convert to JPEG and compress the quality
                                    
                                    let compressedData = uiImage.jpegData(compressionQuality: 1)
                                    selectedImageData = compressedData
                                }
                                
                                
                                
                            }
                        }
                        .onAppear() {
                            dismissKeyboard_func()

                        }
                        
                        Text("\(diaryText.count)/3000")
                            .frame(width: geometry.size.width*0.45, alignment: .trailing)
                        
                    }
                    
                    
                    
                    
                    Button(action:{
                        if !(selectedImageData == nil && diaryText == "") {
                            addDiary()
                        }
                        popUp_addDiary.toggle()
                    }) {
                        Text( (selectedImageData == nil && diaryText == "") ? "취소" :"완료")
                    }
                    .buttonStyle(.bordered)

                    
                } // Vstack
                .frame(width:geometry.size.width, height: geometry.size.height, alignment: .top)
                .background()
                .dismissingKeyboard()
                

                
                TextEditor(text: $diaryText)
                    .frame(width: textBoxWidth, height: textBoxHeight, alignment: .top)
                    .shadow(color:shadowColor, radius: 5)
                    .scrollDisabled(false)
                    .maxLength(3000, text: $diaryText)
                    .position(x: geometry.size.width/2, y: imageTopPointPadding + spacingBetweenImageAndTextBox + textBoxHeight/2 + ( selectedImageData != nil ? imageHeight : 0.0))
                    .zIndex(2)
                    
                    
                    

                
                
                
                
                
                
            } // zstack
            .frame(width:geometry.size.width, height:geometry.size.height, alignment:.top)
            .onAppear {
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                    //                    let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    //                    let height = value.height
                    withAnimation {
                        keyboardAppeared = true
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    withAnimation {
                        keyboardAppeared = false
                    }
                }
            }
            
        }// geometry reader



    }
    
    func addDiary() -> Void {
        
        
        selectedDailyRecord.dailyText = diaryText
        selectedDailyRecord.dailyTextType = DailyTextType.diary // 순서 위에거 하고 바뀌면 안됨: optionalType에서 ! 걸림
        selectedDailyRecord.diaryImage = selectedImageData

    }
    
}




// feedback: deprecated
//    else if chosenDiaryTopic  == DiaryTopic.feedbacks {
//        VStack {
//            Text("여러 퀘스트를 수행하며\n오늘 하루 깨달은 점을 적어보세요!")
//            
//            ForEach(text_feedbacks.indices,id:\.self) { index in
//                
//                HStack {
//                    TextField("",text: $text_feedbacks[index])
//                    let picker =
//                    Picker("",selection: $category_feedbacks[index]) {
//                        ForEach(recoraddic.defaultPurposes, id:\.self) {
//                            Text($0)
//                        }
//                    }
//                    Button(action:{
//                        category_feedbacks.remove(at: index)
//                        text_feedbacks.remove(at: index)
//                    })
//                    {
//                        Image(systemName: "minus.circle")
//                    }
//                    
//                }
//                .background(.gray)
//                .clipShape(.buttonBorder)
//                .padding(5)
//                .shadow(radius: 3)
//
//            }
//            Button(action:{
//                text_feedbacks.append("")
//                category_feedbacks.append("")
//
//            }) {
//                Image(systemName: "plus.circle")
//            }
//        }
//        .onChange(of:text_feedbacks) {
//            
//        }
//    }
