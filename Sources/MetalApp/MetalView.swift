//
//  MetalView.swift
//  
//
//  Created by Christian Treffs on 25.02.21.
//

import Metal
import QuartzCore

final class MetalView: APPLView {
    lazy var mtlLayer: CAMetalLayer = {
        #if os(macOS)
        wantsLayer = true
        #endif
        guard let layer = layer as? CAMetalLayer else {
            fatalError("Not a metal layer")
        }
        return layer
    }()

    #if os(macOS)
    override func makeBackingLayer() -> CALayer { CAMetalLayer() }
    #else
    override class var layerClass: AnyClass { CAMetalLayer.self }
    #endif
}
