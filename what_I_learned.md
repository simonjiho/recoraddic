#  <#Title#>



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



# swift




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
