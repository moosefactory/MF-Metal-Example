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

//  AccumulatorLayer.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 31/08/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

open class AccumulatorLayer: CALayer {
    
    public enum Errors: String, Error {
        case cantCreateZeroSizeBitmap
        case notEnoughMemoryToCreateBitmap
        case cantRenderBitmapNotSet
    }
    
    public var bitmap: CGContext?
    
    public var bitmapSize: CGSize? {
        guard let bitmap = bitmap else { return nil }
        return CGSize(width: bitmap.width, height: bitmap.height)
    }
    
    public var cachedImage: CGImage?
    
    public var invalidRect: CGRect? = nil
    
    /// Time passed in bitmap transfer
    public var transferTime: TimeInterval = 0

    // MARK: - Initialize
    
    public init(size: CGSize, bitmapSize: CGSize? = nil) throws {
        super.init()
        frame = CGRect(origin: .zero, size: size)
        try setBitmapSize(bitmapSize ?? size)
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
        super.init(coder: coder)
        setup()
    }

    open func setup() {
        needsDisplayOnBoundsChange = true
        allowsEdgeAntialiasing = true
    }

    // MARK: - Bitmap creation
    
    public func setBitmapSize(_ newSize: CGSize) throws {
        if bitmap?.width != Int(newSize.width) || bitmap?.height != Int(newSize.height) {
            bitmap = try createBitMap(size: newSize)
        }
    }

    func createBitMap(size: CGSize) throws -> CGContext {
        return try BitmapUtils.createBitMap(size: size)
    }

    // MARK: - Invalidation

    // Invalidate passed rect ( ivalidates bounds if nil ) and request display
    public func flush(rect: CGRect? = nil) {
        if let rect = rect {
            invalidate(rect: rect)
        } 
        setNeedsDisplay(invalidRect ?? bounds)
    }
        
    public func invalidate(rect: CGRect) {
        if let invalidRect = self.invalidRect {
            self.invalidRect = invalidRect.union(rect)//.normalize.alignOnGrid(step: 16)
            return
        }
        self.invalidRect = rect
    }
    
    public override func draw(in ctx: CGContext) {
        let invalidRect = self.invalidRect ?? bounds
        let chronometer = Date()

        ctx.saveGState()

        guard let bitmap = bitmap else { return }
        
        // Revert axis ( offscreen/screen conversion )
        let cropImageRect = CGRect(x: invalidRect.minX, y: CGFloat(bounds.height) - invalidRect.minY - invalidRect.height,
                                   width: invalidRect.width, height: CGFloat(invalidRect.height))

        if let image = bitmap.makeImage(), let cropImage = image.cropping(to: cropImageRect) {
            ctx.draw(cropImage, in: invalidRect)
        }
        
        ctx.restoreGState()
        transferTime += chronometer.timeIntervalSinceNow
        self.invalidRect = nil
    }

    // MARK: - Clear / Restore
    
    open func clear() throws {
        guard let bitmap = bitmap else {
            throw Errors.cantRenderBitmapNotSet
        }
        bitmap.clear(bounds)
        flush()
    }
    
    open func restoreCachedImage() throws {
        try clear()
        guard let image = cachedImage else { return }
        bitmap?.draw(image, in: bounds)
        flush()
    }
}

// MARK: - Pixel scan utils

extension AccumulatorLayer {
    public func rawScan(componentsGenerator: RawScanParameters) {
        bitmap?.rawScan(componentsGenerator: componentsGenerator)
    }

    public func scan(ctm: CGAffineTransform, userInfo: inout Any?, componentsGenerator: ScanParameters) {
        bitmap?.scan(ctm: ctm, userInfo: &userInfo, componentsGenerator: componentsGenerator)
    }
    
    public func scan(tileSize: Int, userInfo: inout Any?, ctm: CGAffineTransform, componentsGenerator: ScanParameters) {
        bitmap?.scan(ctm: ctm, userInfo: &userInfo, componentsGenerator: componentsGenerator)
    }

    public func scanTile(_ tile: Tile, userInfo: inout Any?, ctm: CGAffineTransform, componentsGenerator: ScanParameters) {
        bitmap?.scanTile(tile, userInfo: &userInfo, ctm: ctm, componentsGenerator: componentsGenerator)
    }

}

#endif
