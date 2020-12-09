/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MooseFactory Foundation - v2.0                   */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             (c)2007-2020 Tristan Leblanc                     */
/*        (oo)             tristan@moosefactory.eu                          */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
/*
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */
/*--------------------------------------------------------------------------*/

//  FPLayer.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 20/11/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

/// FPLayer is a CALayer subclass that adds four main features:
///
/// -> A setup function that is called after init, to avoid overriding init in subclass in some cases
/// -> A context scale, that scale line widths. This is usefull to keep a constant line width when
///    layer is affected by a superlayer subtransform
/// -> A representedObject to link layer with a model
/// -> A userInteractionIsEnabled to disable the hitTest function

open class FPLayer: CALayer {
    
    public var userInteractionIsEnabled: Bool = true
    
    public var representedObject: Any? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Set the context scale
    ///
    /// If layer is scaled by superlayer transform, settings contextScale let FPLayer objects keep a constant line width.
    public var contextScale: CGFloat = 1 {
        didSet {
            for sublayer in (sublayers as? [FPLayer]) ?? [] {
                sublayer.contextScale = contextScale
            }
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    //MARK: - Initializers
    
    public init(in targetLayer: CALayer? = nil) {
        super.init()
        if let targetLayer = targetLayer {
            targetLayer.addSublayer(self)
            frame = targetLayer.bounds
        }
        setup()
    }

    public override init() {
        super.init()
        setup()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    
    /// setup is called once the layer is inited
    open func setup() {
        
    }

    open override func hitTest(_ p: CGPoint) -> CALayer? {
        return userInteractionIsEnabled ? super.hitTest(p) : nil
    }
    
    //MARK: - Get/Set line width
    
    public func constantLineWidth(for lineWidth: CGFloat) -> CGFloat { lineWidth / max(0.01, contextScale) }
    
    public func setConstantLineWidth(ctx: CGContext, lineWidth: CGFloat) {
        ctx.setLineWidth(constantLineWidth(for: lineWidth))
    }
}

#endif
