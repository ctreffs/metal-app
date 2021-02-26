//
//  MetalViewController.swift
//  
//
//  Created by Christian Treffs on 25.02.21.
//

import Metal
import QuartzCore

#if canImport(AppKit)
import AppKit
#endif

final class MetalViewController: APPLViewController {

    let valuesPerVertex: Int = 8 // 4 position + 4 color values
    let vertexData: [Float] = [
        // Position[4]          Color[4]
        -0.5, -0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, // left  - red
        +0.0, +0.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, // top   - green
        +0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0  // right - blue
    ]

    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    var displayLink: APPLDisplayLink?

    lazy var mtlView = MetalView()

    override func loadView() {
        self.view = mtlView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtlDevice: MTLDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("No Metal device")
        }

        // Blue Green Red Alpha; UInt8 0-255

        mtlView.mtlLayer.device = mtlDevice
        mtlView.mtlLayer.pixelFormat = .bgra8Unorm

        let dataSize = vertexData.count * MemoryLayout<Float>.stride
        vertexBuffer = mtlDevice.makeBuffer(bytes: vertexData,
                                            length: dataSize,
                                            options: [.storageModeShared])

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.stride * 4
        vertexDescriptor.attributes[1].bufferIndex = 0

        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 8
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        let mtlLib: MTLLibrary = Self.makeShaderLibrary(mtlDevice)
        let fragmentProgram = mtlLib.makeFunction(name: "basic_fragment")!
        let vertexProgram = mtlLib.makeFunction(name: "basic_vertex")!

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = .invalid
        pipelineStateDescriptor.stencilAttachmentPixelFormat = .invalid

        pipelineState = try! mtlDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = mtlDevice.makeCommandQueue()

        createDisplayLink()
    }

    private func makePassDescriptor(_ drawable: CAMetalDrawable) -> MTLRenderPassDescriptor {
        let desc = MTLRenderPassDescriptor()
        desc.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        desc.colorAttachments[0].loadAction = .clear
        desc.colorAttachments[0].storeAction = .store
        desc.colorAttachments[0].texture = drawable.texture
        return desc
    }

    func renderFrame(_ dt: Double) {
        guard let drawable = mtlView.mtlLayer.nextDrawable() else {
            fatalError("No drawable")
        }

        guard let cmdBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("No command buffer")
        }

        guard let encoder = cmdBuffer.makeRenderCommandEncoder(descriptor: makePassDescriptor(drawable)) else {
            fatalError("No Encoder")
        }

        encoder.setRenderPipelineState(pipelineState)

        vertexData.withUnsafeBufferPointer {
            vertexBuffer.contents()
                .assumingMemoryBound(to: Float.self)
                .initialize(from: $0.baseAddress!, count: vertexData.count)
        }

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        encoder.drawPrimitives(type: .triangle,
                               vertexStart: 0,
                               vertexCount: vertexData.count / valuesPerVertex)

        encoder.endEncoding()

        cmdBuffer.present(drawable)
        cmdBuffer.commit()

    }

}

// MARK: - Shader loading
extension MetalViewController {
    static func makeShaderLibrary(_ mtlDevice: MTLDevice) -> MTLLibrary {

        if let defaultLib = mtlDevice.makeDefaultLibrary() {
            print("Shader via default library.")
            return defaultLib

        } else if let shaderFile = Bundle.main.url(forResource: "Shader", withExtension: "metal") {
            do {
                print("Shader from metal file.")
                let source = try String(contentsOf: shaderFile, encoding: .utf8)
                return try mtlDevice.makeLibrary(source: source,
                                                 options: nil)
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            var fileURL = URL(fileURLWithPath: #file)
            fileURL.deleteLastPathComponent()
            fileURL.appendPathComponent("Shader.metal")
            do {
                print("Shader from metal #file.")
                let source = try String(contentsOf: fileURL, encoding: .utf8)
                return try mtlDevice.makeLibrary(source: source,
                                                 options: nil)

            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}

// MARK: - DisplayLink
extension MetalViewController {

    func createDisplayLink() {
        #if os(macOS)
        createCVDisplayLink()
        #else
        createCADisplayLink()
        #endif
    }

    #if canImport(UIKit)
    private func createCADisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
        displayLink?.add(to: .main, forMode: .common)
        print("CADisplayLink created ... running")
    }

    @objc private func tick(_ displayLink: APPLDisplayLink) {
        renderFrame(displayLink.duration)
    }

    #else

    private func createCVDisplayLink() {
        func displayLinkOutputCallback(_ displayLink: CVDisplayLink,
                                       _ nowPtr: UnsafePointer<CVTimeStamp>,
                                       _ outputTimePtr: UnsafePointer<CVTimeStamp>,
                                       _ flagsIn: CVOptionFlags,
                                       _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                                       _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
            let metalViewController = unsafeBitCast(displayLinkContext, to: MetalViewController.self)

            let timestamp: CVTimeStamp = outputTimePtr.pointee
            let dt = Double(timestamp.videoRefreshPeriod) / Double(timestamp.videoTimeScale)

            autoreleasepool {
                metalViewController.renderFrame(dt)
            }
            return kCVReturnSuccess
        }

        let displayId = UInt32(APPLScreen.main!.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! Int)

        CVDisplayLinkCreateWithCGDisplay(displayId, &self.displayLink)
        CVDisplayLinkSetOutputCallback(self.displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(self.displayLink!)
        print("CVDisplayLink created ... running")
    }
    #endif
}
