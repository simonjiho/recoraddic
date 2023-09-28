//
//  allRecordPieces.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/11.
//

// 지금은 2d 느낌으로 가지만, 나중에는 3d도...
// 2023.08.21 -> 코드 정리 필요(렌더링 파이프라인의 과정 구조에 따라 함수로 묶기(특히 init과 draw안에 있는 것들)

// 3d로 만들면, 조명으로 인한 그림자 효과 만들기


import Foundation
import SwiftUI
import MetalKit
import simd
import Metal
import SwiftData

// let's list all the procedure of renderer1 and renderer2 then compare it

struct AllRecordPieces: View {
    
//    @Bindable var records: Records
    
//    var currentRecord: Record
//    var dailyStonesUIData: DailyStoneData
//    var recordStonesUIData: RecordStoneData
    
    init(records: [Record]) {
//        self.records = records
        
//        dailyStonesUIData = DailyStoneData(color: <#T##Float#>, size: <#T##Float#>)
//        self.records
    }
    
    
    
    
    
    var body: some View {
        #if os(macOS)
        return AnyView(MacCustomView())
        #else
        return AnyView(IOSCustomView())
        #endif
    }
}


let sampledata: AllRecordStonesData = AllRecordStonesData(recordData: [RecordStoneData(color: 1.0, size: 10.0), RecordStoneData(color: 1.0, size: 10.0), RecordStoneData(color: 1.0, size: 10.0)], dailyData: [DailyStoneData(color: 1.0, size: 10.0), DailyStoneData(color: 1.0, size: 10.0), DailyStoneData(color: 1.0, size: 10.0)])






// This part is twin data structure of .metal file. If this way is not available or uncomfortable,
// this data would be implemented in header file, and then import in the bridging header.

//enum VertexInputIndex
//{
//    case VertexInputIndexVertices // = 0
//    case VertexInputIndexViewportSize // = 1
//} // how to match with corresponding numbers?

let VertexInputIndexVertices = 0
let VertexInputIndexViewportSize = 1
let VertexInputIndexTranslation = 2


#if os(macOS)
struct MacCustomView: NSViewRepresentable {
    let device = MTLCreateSystemDefaultDevice()!
    var renderer: Renderer1
    let mtkView: MTKView
    
    init() {
        mtkView = MTKView(frame: .zero, device: device)
        renderer = Renderer1(metalKitView: mtkView)
    }

    
    func makeNSView(context: Context) -> MTKView {
        mtkView.delegate = renderer
        mtkView.preferredFramesPerSecond = 60
        mtkView.framebufferOnly = false // energy performance low, but can interact
        mtkView.clearColor = MTLClearColor(red: 0.95, green: 0.9, blue: 0.7, alpha: 1.0)
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.drawableSize = mtkView.frame.size
        
        
        // Add a tracking area to the view to receive mouse events
        let trackingArea = NSTrackingArea(rect: mtkView.bounds, options: [.activeAlways, .mouseMoved, .inVisibleRect], owner: mtkView, userInfo: nil)
        mtkView.addTrackingArea(trackingArea)
        
//        // Set up event handlers
        mtkView.onMouseDown = renderer.mouseDown
        mtkView.onMouseUp = renderer.mouseUp
        mtkView.onMouseDragged = renderer.mouseDragged
        
//
        
        print(mtkView.drawableSize)
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
    

}
#endif




#if os(iOS)

struct IOSCustomView: UIViewRepresentable {
    let device = MTLCreateSystemDefaultDevice()
    var renderer: Renderer1
    let mtkView: MTKView
    
    init() {
        mtkView = MTKView(frame: .zero, device: device)
        renderer = Renderer1(metalKitView: mtkView)
    }

    
    func makeUIView(context: Context) -> MTKView {
        mtkView.delegate = renderer
        mtkView.preferredFramesPerSecond = 60
        mtkView.framebufferOnly = false // energy performance low, but can interact
        mtkView.clearColor = MTLClearColor(red: 0.95, green: 0.9, blue: 0.7, alpha: 1.0)
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.drawableSize = mtkView.frame.size
        mtkView.depthStencilStorageMode = MTLStorageMode.private
        
        
        // Set up gesture recognizers
//        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
//        mtkView.addGestureRecognizer(tapGestureRecognizer)
//
//        let panGestureRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
//        mtkView.addGestureRecognizer(panGestureRecognizer)
//
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {}
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(renderer: renderer)
//    }
//
//    class Coordinator: NSObject {
//        var renderer: Renderer1
//
//        init(renderer: Renderer1) {
//            self.renderer = renderer
//        }
//
//        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
//            let location = gestureRecognizer.location(in: gestureRecognizer.view)
//            renderer.mouseDown(atPoint: location)
//        }
//
//        @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
//            let location = gestureRecognizer.location(in: gestureRecognizer.view)
//            switch gestureRecognizer.state {
//            case .began:
//                renderer.mouseDown(atPoint: location)
//            case .changed:
//                renderer.mouseDragged(toPoint: location)
//            case .ended:
//                renderer.mouseUp(atPoint: location)
//            default:
//                break
//            }
//        }
//    }
}
#endif






class Renderer1: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var pipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
//    var depthTexture: MTLTexture!
    var commandQueue: MTLCommandQueue!
    var viewportSize = vector_uint2()
    
    #if os(macOS)
    var mouseDownPoint: NSPoint!
    #else
    var tapDownPoint: CGPoint!
    #endif
    
    var stonePosition: SIMD4<Float>!
    var stoneSpeedY: Float!
    var stone2: Stone!
    var data: AllRecordStonesData!
    var dailyStones: [Stone] = []
    var recordStones: [Stone] = []
    
    var clickgap: SIMD2<Float>!
    
    var deltaTime: Float!
//    var timeStack: Int!

    init(metalKitView mtkView: MTKView) {
        device = mtkView.device!
        super.init()

        // Load all the shader files with a .metal file extension in the project.
        let defaultLibrary = device.makeDefaultLibrary()!

        let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader")
        let fragmentFunction = defaultLibrary.makeFunction(name: "fragmentShader")

        // Configure a pipeline descriptor that is used to create a pipeline state.
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Simple Pipeline"
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        

        // Set the depth pixel format
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        
        // Create a depth stencil descriptor
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        
        // Create the depth stencil state
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        

        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }

        // Create the command queue
        commandQueue = device.makeCommandQueue()
        
        deltaTime = 1.0 / Float(mtkView.preferredFramesPerSecond)
        

        

        data = sampledata // 나중에는 저장된 데이터 정보에서 가져와서 구성해야함
        
        
        
        
        
        var stone1InitPosition = SIMD4<Float>(0,0,0.9,1)
        let stone1InitSpeedY: Float = 0.0
        
        
        var color1:Float = 0.01
        for recordStoneData in data.recordStonesData {
            recordStones.append(Stone(initPosition: stone1InitPosition, initSpeedY:stone1InitSpeedY, colorFactors: SIMD3<Float>(0.8, 0.7, color1), interval: deltaTime))
            stone1InitPosition.w -= 0.01
            color1 += 0.4
        }

        
        let stone2InitPosition = SIMD4<Float>(0,0,0.5,1)
        let stone2InitSpeedY: Float = 5.0
        
        
        var color2:Float = 0.99
        for dailyStoneData in data.dailyStonesData {
            dailyStones.append(Stone(initPosition: stone2InitPosition, initSpeedY:stone2InitSpeedY, colorFactors: SIMD3<Float>(1.0, 0.7, color2), interval: deltaTime))
            color2 -= 0.01
        }
        
        stone2 = Stone(initPosition: stone2InitPosition, initSpeedY:stone2InitSpeedY, colorFactors:SIMD3<Float>(1.0, 0.3, 0.9), interval: deltaTime)
        
        #if os(macOS)
        mouseDownPoint = NSPoint(x: 0.0, y: 0.0)
        #else
        tapDownPoint = CGPoint(x: 0.0, y: 0.0)
        #endif
        print("mtkview initialized")
    }

    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Save the size of the drawable to pass to the vertex shader.
        viewportSize.x = UInt32(size.width) // 왜인지 모르겠는데, 설정값의 두배가 나와서 2로 나누어줌
        viewportSize.y = UInt32(size.height) // 왜인지 모르겠는데, 설정값의 두배가 나와서 2로 나누어줌
        print(viewportSize)
//        viewport = view.window?.frame
    }
    
    
    #if os(macOS)
    func mouseDown(with event: NSEvent, in view: NSView) {
        

        
        let sizeX = view.frame.width
        let sizeY = view.frame.height
        let rawPoint = view.convert(event.locationInWindow, from: nil)
        
        mouseDownPoint = NSPoint(x: rawPoint.x - sizeX/2.0, y: rawPoint.y - sizeY/2.0)
        
        let point = SIMD2<Float>(x:Float(mouseDownPoint.x), y:Float(mouseDownPoint.y))
//        print("clicked point: ", point)

        

        
        
        // 가장 앞에 있는 놈만 선별하는 과정 필요
        var mostFrontStone: Stone?
        for recordStone in recordStones {
            if recordStone.isInterior(point: point) { // isInterior 함수 부정확: 바깥범위에서도 isInterior 잡힘
                if mostFrontStone == nil || (mostFrontStone!.center.w > recordStone.center.w) { mostFrontStone = recordStone }
    //            print("stone's position: \n", pos1)
    //            print(point)
            }
        }
        
        if mostFrontStone != nil {
            mostFrontStone!.stoneIsHeld = true
            let pos1 = SIMD2<Float>(x:mostFrontStone!.center.x, y:mostFrontStone!.center.y)
            clickgap = point - pos1
        }

        // 가장 앞에 있는 놈만 잡히게
        // 잡힌 놈은 가장 앞으로 당겨오기 -> 나중에
        // 애초에 겹치지 않게 하기...? 안해도 될것 같긴 함
        
        
    }
    
    func mouseUp(with event: NSEvent, in view: NSView) {
        
        for recordStone in recordStones {
            recordStone.stoneIsHeld = false
        }
    }
    
    
    
    func mouseDragged(with event: NSEvent, in view: NSView) {
        
        var anyStoneIsHeld = false
        for recordStone in recordStones {
            if recordStone.stoneIsHeld {
                anyStoneIsHeld = true
            }
        }
        if !anyStoneIsHeld {return}
        
//        print(event.deltaX)
        let sizeX = view.frame.width
        let sizeY = view.frame.height
        let rawPoint = view.convert(event.locationInWindow, from: nil)
//
        let mouseDraggedPoint = NSPoint(x: rawPoint.x - sizeX/2.0, y: rawPoint.y - sizeY/2.0)
        let anchorPoint = SIMD2<Float>(x:Float(mouseDraggedPoint.x) - clickgap.x, y:Float(mouseDraggedPoint.y) - clickgap.y)
        
        
        for recordStone in recordStones {
            if recordStone.stoneIsHeld {
                recordStone.move(point: anchorPoint)
            }
        }

//
//        stone1.position.x += Float(event.deltaX)
//        stone1.position.y += Float(event.deltaY)
        
    }
    #endif
    
    func draw(in view: MTKView) { // vector_float4 == SIMD4<Float>
        

        // Create a texture descriptor for the depth texture
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(view.drawableSize.width), height: Int(view.drawableSize.height), mipmapped: false)
        depthTextureDescriptor.usage = .renderTarget
        
        // only for simulator
        #if targetEnvironment(simulator)
        depthTextureDescriptor.storageMode = .private
        #endif
        
//        // Create the depth texture
        let depthTexture = device.makeTexture(descriptor: depthTextureDescriptor)!
        
        for recordStone in recordStones {
            recordStone.move()
        }
        
        stone2.move()
        

        
        // Create a new command buffer for each render pass to the current drawable.
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.label = "MyCommand"
        
        
        // Obtain a renderPassDescriptor generated from the view's drawable textures.
        if let renderPassDescriptor = view.currentRenderPassDescriptor {
            
            
            
            



            // Set the depth attachment texture of the render pass descriptor
            renderPassDescriptor.depthAttachment.texture = depthTexture
            
            
            
            
            
            // Create a render command encoder.
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderEncoder.label = "MyRenderEncoder"

            // Set the region of the drawable to draw into.
            renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0,
                                                  width: Double(viewportSize.x), height: Double(viewportSize.y),
                                                  znear: 0.0, zfar: 1.0))

            renderEncoder.setRenderPipelineState(pipelineState)
            
//            setDepthStencilState is unavailable.. why?
            renderEncoder.setDepthStencilState(depthStencilState)

            
            
            

            
            
            for recordStone in recordStones {
                
                // need to change to setVertexBuffer if each data exceeds 4kb.
                renderEncoder.setVertexBytes(recordStone.Vertices,
                                             length: MemoryLayout<VerIn>.stride * recordStone.Vertices.count,
                                             index: Int(VertexInputIndexVertices))
                renderEncoder.setVertexBytes(&viewportSize,
                                             length: MemoryLayout<vector_uint2>.stride,
                                             index: Int(VertexInputIndexViewportSize))
                // Draw the triangle.
                renderEncoder.drawPrimitives(type: .triangleStrip,
                                             vertexStart: 0,
                                             vertexCount: recordStone.Vertices.count,
                instanceCount: 2) // instanceCount meaningless. How can i use this?
            }
            
            
            

            
            
            
            
            
            renderEncoder.setVertexBytes(stone2.Vertices,
                                         length: MemoryLayout<VerIn>.stride * stone2.Vertices.count,
                                         index: Int(VertexInputIndexVertices))
            renderEncoder.setVertexBytes(&viewportSize,
                                         length: MemoryLayout<vector_uint2>.stride,
                                         index: Int(VertexInputIndexViewportSize))
            // Draw the triangle.
            renderEncoder.drawPrimitives(type: .triangleStrip,
                                         vertexStart: 0,
                                         vertexCount: stone2.Vertices.count,
            instanceCount: 2)
            
            
            
            
            
            
            
            
            
            

            renderEncoder.endEncoding()
            
            
            // Schedule a present once the framebuffer is complete using the current drawable.
            commandBuffer.present(view.currentDrawable!)
        }

        // Finalize rendering here & push the command buffer to the GPU.
        commandBuffer.commit()
    }
}













#if os(macOS)
extension NSView {
    private struct AssociatedKeys {
        static var onMouseDown = "onMoujseDow"
        static var onMouseUp = "onMouseUp"
        static var onMouseDragged = "onMouseDragged"
    }
    
    typealias MouseEventHandler = (NSEvent, NSView) -> Void
    
    var onMouseDown: MouseEventHandler? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onMouseDown) as? MouseEventHandler
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onMouseDown, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var onMouseUp: MouseEventHandler? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onMouseUp) as? MouseEventHandler
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onMouseUp, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }


    
    var onMouseDragged: MouseEventHandler? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onMouseDragged) as? MouseEventHandler
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onMouseDragged, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    
    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        
        onMouseDown?(event, self)
    }
    
    
    open override func mouseUp(with event: NSEvent) {
        super.mouseDown(with: event)

        
        onMouseUp?(event, self)
    }
    
    open override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        
        onMouseDragged?(event, self)
    }
    

}
#endif





