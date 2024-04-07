#  <#Title#>



# git
- pull안하고 변경한 다음에 다시 pull하면 rebase체크하면 전부 사라진다.

# 주요 용어
 - ~Delegate
 - ~Representable: wraps the ~, to integrate with View
 - ~Controller
 - 


# need to learn
 - concurrency models
 - macros and customized macros
 - swiftdata
 - how to mix c++ code with swift

# general
  - float variable =  float(int / int) -> 0 (X)
  - float variable = float / float (O)
   - properties in class does not change from the outside of the instance. should be modified using method.
  - for customization of ui...
    simple -> SwiftUI
    simple, but not in SwiftUI -> UIView, NSView
    simple, but impossible to implement by UIView & NSView -> metal
    complex design -> metal

 - SwiftUI -> general
 - UIKit -> iOS, ipadOS
 - AppKit -> macOS
 - UIView and NSView belongs to default library, it is activated based on the OS detection. (Ex: iOS -> UIView activated, NSView deactivated)
 - @Published -> make variable observable outside the object.
 - in OrderedCollection library, there's OrderedDictionary that have order for each element
 - 다른 폴더여도 같은 프로젝트에 같은 파일이름 있으면 안됨 -> error message: "multiple commands produced" 


# swift
 - list.enumerated -> (int, element) pairs



# SwiftUi
 - Uses View(Protocol)
    - compatible to almost every OS of apple
    - So use it as much as you can
 - Uses ~Representable
    - wraps NSView, UIView, UIViewController, NSViewController, etc..?

 - to build customized views....
    for ios: UIViewRepresentable
    for macos: NSViewRepresentable
    for watchos: WKInterfaceObjectRepresentable
    note that: Each Protocols are mutually exclusive
    
 - In View, View can't detect the changes of variable that is not the state of it. The View's element is only mutable by State of it. Other can't do that.
    (maybe should use @Observable/@Environment..? and)
    
 - You can integrate SwiftUI views with objects from the UIKit, AppKit, and WatchKit frameworks to take further advantage of platform-specific functionality. You can also customize accessibility support in SwiftUI(and also UIKit), and localize your app’s interface for different languages, countries, or cultural regions.
    
 - ~Representable -> 
 
 - Use @Observable(Object) and @EnvironmentObject to store the View's data for showing users feel continuous motions even when view reinitialized (switching the tab always results in deallocation and reinitializtion of View)
 - Variables that have @Published property inside @ObservableObject will make the view rerendered when modified.
 - withAnimation controls the animation of the view, the view whose existence is determined by conditional statement. Those conditional statement is controlled by the value related to withAnimation closure. 
    
 - View의 @State variable이 선언되지 않으면 이상한 곳에서 compile 에러 발생 (~ buildExpression 어쩌구 저쩌구..)
 
 - Always in mind, SwiftUI's frame origin is top-leading edge of square frame
 
 - View's modifier is adjusted from the bottom, in other words, from the last one.
 
 - Stack is the view with automatic frame size, so if you want to fix the size, you should use .frame() on it.

                        // frame -> padding : padding added outside frame
                        // padding -> frame : padding inside frame
                        // position -> frame : positioned based on the parent view's coordinate system
                        // frame -> position : positioned based on the frame's coordinate system + frame size destroyed
- stack(alignment) -> stack의 element들의 크기에 따라 임의의 frame정하고, 각 element들이 그 frame안에서 어떻게 정렬되는지
- stack().frame(alignment) -> stack이 들어갈 frame의 크기를 정하고, stack뭉텡이가 그 frame안에서 어느쪽으로 정렬될지 
- ForEach View 관련 error에서 원인을 못찾겠다면, 안의 구현이 잘못된 경우가 많다. 에러메시지가 이상하게 뜨니, 그걸로 분석하려 하지 말것.
- scrollViewReader : id 설정해서 id있는 쪽으로 자동 스크롤 되는 버튼 만들 수 있음(show quick help 참조)
- CGRect.frame(in:) 은 바깥의 뷰가 자기가 종속하고 있고, 사이즈를 자신의 사이즈에 의해 결정하는 내부 뷰의 좌표계를 참조 할 수 없다.
- .popOver : 위에서 아래로 쓸어내리면 사라지는 popUp
- .contextMenu : 오래 누르고 있으면 나오는 메뉴
- Form : 디바이스에 맞게 form을 자동 렌더링 해줌, textfield, picker, 등등 사용. setting에 사용 가능.
- 왜인지 모르겠는데 tabview를 전환했다가 gritBoard 다시 들어가면 들어갈 수록 frame전환 횟수가 빨라짐
- computed properties are really heavy. Don't use it if necessary

# UIKit
 - older than SwiftUI, so if not necessary, use SwiftUI as much as you can. Apple will support more on SwiftUI, not UIKit.
 - Use UIKit classes only from your app’s main thread or main dispatch queue, unless otherwise indicated in the documentation for those classes. This restriction particularly applies to classes that derive from UIResponder or that involve manipulating your app’s user interface in any way.




# MetalKit
 - uses MTKView: View that has renderer that can draw from scratch.
    - Changes it's behavior based on the OS it is on. ( UIView <-> NSView )
    - Hence, need to be wrapped by ~Representable to integrate with View from SwiftUI

# Metal
 - metal also has an slight differences in specific rendering process
 - to make efficient animation, core animation is recommanded. -> animation that is not rendered, just displayed.
    - But then, you may need to integrate core animation and metal-based rendered view using CAMetalLayer, not mtkView.


 - some render performance optimizating options to study:
    - Culling: Culling involves removing objects or parts of objects that are not visible to the camera, so they don’t need to be rendered. This can reduce the number of draw calls and the amount of data that needs to be processed by the GPU.

    - Level of Detail (LOD): Level of detail involves using simplified versions of objects when they are far away from the camera, so they require less processing power to render. This can reduce the number of vertices and triangles that need to be processed by the GPU.

    - Occlusion Culling: Occlusion culling involves removing objects that are hidden behind other objects, so they don’t need to be rendered. This can reduce the number of draw calls and the amount of data that needs to be processed by the GPU.

    - Batching: Batching involves grouping multiple objects into a single draw call, so they can be rendered more efficiently. This can reduce the number of draw calls and the amount of data that needs to be sent to the GPU.

    - Texture Compression: Texture compression involves compressing texture data so it takes up less memory and bandwidth. This can reduce the amount of data that needs to be transferred to the GPU and improve performance.

    - These are just a few examples of techniques you can use to optimize rendering performance in Metal. The best approach for your specific use case will depend on many factors, such as the complexity of your scene, the number of objects, and the hardware you’re targeting.
