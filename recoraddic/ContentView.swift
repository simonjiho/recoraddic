//
//  ContentView.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//


// make configuration of some features, such as the view's size for each device


// need to integrate imports in one file
import SwiftUI
import SwiftData

class SelectedView: ObservableObject {
    
    enum ViewName {
        case home
        case recommendations
        case getRectanyl
        case shelf
        case shop
    }
    
    @Published var name: ViewName
    
    init() {
        self.name = .home
    }
    
}


struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // sort by the fixed order later on
    @Query(sort:\Record.name) private var records: [Record]
    // 여기서 순서 지정
    let viewNames: [SelectedView.ViewName] = [.home, .recommendations, .getRectanyl, .shelf, .shop]
    
    let images: [SelectedView.ViewName:String] = [
        .home : "house",
        .recommendations: "magnifyingglass",
        .getRectanyl: "record.circle",
        .shelf: "trophy",
        .shop: "pills.circle"
    ] // (view name) : (ImageName)
    
//    @Bindable var data: Data = SampleData()
    @StateObject var selectedView: SelectedView = SelectedView() //HomeView
    
    @State var isRecordTodayActivated: Bool = false
    
    
     var body: some View {
         if isRecordTodayActivated {
             RecordTodayView(currentRecord: records[0], isRecordTodayActivated: $isRecordTodayActivated)
//                 .onAppear(perform: {
//                     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                         print("length of dailyRecords after added")
//                         records[0].dailyRecords.append(DailyRecord(date:.now))
//                     }
//                 })
                 .transition(.slide)
         }
         else {
             ZStack {
                 VStack {
                     Spacer()
                         .frame(height: 50)
                     Button(action: initiateSampleData, label: {
                         Text("initiate sampledata")
                     })
                     Spacer()
                     MainView(records: records, isRecordTodayActivated: $isRecordTodayActivated)
                         .environmentObject(selectedView)
                     Spacer()
                     
                 }
                 VStack {
                     Spacer()
                     HStack {
                         
                         ForEach (viewNames, id: \.self) {viewName in
                             
                             Button(action: {
                                 selectedView.name = viewName
                                 print(selectedView.name)
                             }) {
                                 
                                 Image(systemName: images[viewName]!)
                                     .foregroundColor(viewName == selectedView.name ? .white : .gray)
                                     .modifier(CustomImageStyle())
                                 
                                 
                             }
                             .buttonStyle(CustomButtonStyle())
                             //                             .esnvironmentObject(selectedView)
                             .scaleEffect(viewName == selectedView.name ? 1.2 : 1)
                             
                         }
                         
                         
                         
                         
                     }
                     .frame(height: 800,alignment: .bottom)
                     
                     Spacer().frame(height: 30)
                     
                     
                 }
                 
             }
         }

     }
    

    private func initiateSampleData() -> Void {
        if records[0].purposes.count == 0 {
            records[0].createSample()
        }
    }
}


struct MainView: View {
    @Environment(\.modelContext) private var modelContext

    var records: [Record]
    @EnvironmentObject var selectedView: SelectedView
    
    @Binding var isRecordTodayActivated: Bool
    
    var body: some View {
        
        if selectedView.name == .home {
            MainView_Home()
            // Problem(2023.08.26) : Resets every time when buttons Clicked
        }
        else if selectedView.name == .recommendations {
            MainView_Recommendations()
        }
        else if selectedView.name == .getRectanyl {
            MainView_GetRectanyl(currentRecord: records[0], isRecordTodayActivated: $isRecordTodayActivated)
        }
        else if selectedView.name == .shelf {
            MainView_Shelf(records: records)
        }
        else if selectedView.name == .shop {
            MainView_Shop()
        }
    }
    

    
    
}


struct CustomImageStyle: ViewModifier {
    func body(content: Content) -> some View {
            content
            #if os(iOS)
            .font(.system(size: 24))
            #elseif os(macOS)
            .font(.system(size: 30))
            #endif
            .border(.black)
            .id(UUID())
    }
}

struct CustomButtonStyle: ButtonStyle {
    
    #if os(iOS)
    var width: CGFloat = 40
    var height: CGFloat = 40
    #elseif os(macOS)
    var width: CGFloat = 50
    var height: CGFloat = 50
    #endif
    
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height)
            .background(Color.black.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(8)
            #if os(iOS)
            .padding(10)
            #elseif os(macOS)
            .padding(.horizontal, 40)
            #endif
    }
}















// Usage: to show previews on rightside
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

    }
}
