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

//  CGGeometry.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 19/11/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

// MARK: - Rect utilities -

public extension CGRect {
    
    enum Handle: Int, CaseIterable {
        case center
        case topLeft
        case topMiddle
        case topRight
        
        case middleLeft
        case middleRight
        
        case bottomLeft
        case bottomMiddle
        case bottomRight
        
        var fractionalLocation: CGPoint {
            switch self {
            case .center:
                return CGPoint(x: 0.5, y:  0.5)
            case .topLeft:
                return  CGPoint(x: 0, y:  1)
            case .topMiddle:
                return  CGPoint(x: 0.5, y: 1)
            case .topRight:
                return  CGPoint(x: 1, y:  1)
            case .middleLeft:
                return CGPoint(x: 0, y:  0.5)
            case .middleRight:
                return  CGPoint(x: 1, y:  0.5)
            case .bottomLeft:
                return  CGPoint(x: 0, y: 0)
            case .bottomMiddle:
                return  CGPoint(x: 0.5, y: 0)
            case .bottomRight:
                return  CGPoint(x: 1, y: 0)
            }
        }
                
        func location(on rect: CGRect) -> CGPoint {
            return rect.origin + rect.size.toPoint * fractionalLocation
        }
        
        func frame(on rect: CGRect, size: CGFloat = 3) -> CGRect {
            return location(on: rect).centeredRect(ray: 3)
        }
    }
    
    // MARK: - Interesting points utilities
    
    var boundsCenter: CGPoint {
        return CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    var frameCenter: CGPoint {
        return CGPoint(x: minX + size.width / 2, y: minY + size.height / 2)
    }
    
    var halfWidth: CGFloat { return width / 2 }
    var halfHeight: CGFloat { return height / 2 }
    
    var center: CGPoint { frameCenter }
    var middleLeft: CGPoint { Handle.middleLeft.location(on: self) }
    var middleRight: CGPoint { Handle.middleRight.location(on: self) }
    var topLeft: CGPoint { Handle.topLeft.location(on: self) }
    var topRight: CGPoint { Handle.topRight.location(on: self) }
    var bottomLeft: CGPoint { Handle.bottomLeft.location(on: self) }
    var bottomRight: CGPoint { Handle.bottomRight.location(on: self) }
    var topMiddle: CGPoint { Handle.topMiddle.location(on: self) }
    var bottomMiddle: CGPoint { Handle.bottomMiddle.location(on: self) }
    
    /// Convenience initializer
    init(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) {
        self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    // Mark: - Alignment Utilities
    
    /// Return copy of self, centerd on point
    func centered(on point: CGPoint) -> CGRect {
        return CGRect(origin: point - boundsCenter, size: size)
    }

    func centered(in rect: CGRect) -> CGRect {
        if self == rect { return self }
        return self.centered(on: rect.frameCenter)
    }
    
    /// returns rectangle centered on (0,0)
    var zeroCentered: CGRect {
        return centered(on: .zero)
    }
    
    /// Returns a new rectangle, scaled and centered on self
    func centeredScaledRect(scale: CGFloat) -> CGRect {
        return (self * scale).centered(on: frameCenter)
    }
    
    /// Returns integral rect ( integer coordinates )
    var normalize: CGRect {
        return CGRect(x: Int(minX), y: Int(minY), width: Int(width), height: Int(height))
    }
    
    /// Returns copy of self with bottom left at (0,0)
    var atOriginZero: CGRect {
        return CGRect(origin: .zero, size: size)
    }
    
    /// Returns a copy of self, scaled up and aligned on nearest grid
    ///
    /// This is usefull to update bitmaps on memory boundaries, for optimized performances.
    ///
    /// Extent is used to grow the clipping rect to take line width in account if needed
    func alignOnGrid(step: CGFloat, extent: CGFloat) -> CGRect {
        return CGRect(minX: step * floor((minX - extent) / step),
                      minY: step * floor((minY - extent) / step),
                      maxX: step * ceil((maxX + extent) / step),
                      maxY: step * ceil((maxY + extent) / step))
    }
    
    /// returns rect of given size, aligned to top left corner
    func topLeftRect(width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: 0, y: self.height - height, width: width, height: height)
    }
    
    /// returns hypthenuse
    var hypo: CGFloat {
        return sqrt( width * width + height * height) / 2
    }
    
    func clipped(to clipRect: CGRect) -> CGRect {
        let miX = max(minX, clipRect.minX)
        let miY = max(minY, clipRect.minY)
        let maX = min(maxX, clipRect.maxX)
        let maY = min(maxY, clipRect.maxY)
        return CGRect(x:miX, y: miY, width: maX - miX, height: maY - miY)
    }
    
    /// returns inset rect, using fractional values
    /// - 0 means no inset
    /// - 1 means inset by half ( which is an empty rect in center )
    func insetByPercent(dx: CGFloat, dy: CGFloat) -> CGRect {
        let dx = halfWidth * dx.clampToPositiveFractional
        let dy = halfHeight * dy.clampToPositiveFractional
        return insetBy(dx: dx, dy: dy)
    }
    
    #if os(macOS)
    
    var ns: NSRect {
        return NSRect(x: minX, y: minY, width: width, height: height)
    }

    #endif
}

// MARK: - Scale to fit / to fill -

public extension CGRect {
    
    /// returns scaled rect fitting in passed rect
    ///
    /// returns the result rect, and the applied scale
    func fit(in rect: CGRect) -> (CGRect, CGFloat) {
        let (fittedSize, scale) = size.fit(in: rect.size)
        let out = CGRect(origin: .zero, size: fittedSize)
        return (out.centered(in: rect), scale)
    }
    
    /// returns scaled rect filling passed rect
    ///
    /// returns the result rect, and the applied scale
    func fill(in rect: CGRect) -> (CGRect, CGFloat) {
        let (fittedSize, scale) = size.fill(in: rect.size)
        let out = CGRect(origin: .zero, size: fittedSize)
        return (out.centered(in: rect), scale)
    }
}

public extension CGSize {
    
    // Returns the size mapped to (1,1)
    var fractional: CGSize {
        return self /  max(width, height)
    }
    
    // Returns the size ratio
    var ratio: CGFloat {
        return width / height
    }

    /// returns scaled size fitting passed size
    ///
    /// returns the result size, and the applied scale
    func fit(in size: CGSize) -> (CGSize, CGFloat) {
        if width == 0 || height == 0 { return (.zero, 0) }

        var scale = size.width / width
        let newHeight = height * scale
        if newHeight > size.height {
            scale = size.height / height
        }
        let out = CGSize(width: width * scale, height: height * scale)
        return (out, scale)
    }
    
    /// returns scaled size filling passed size
    ///
    /// returns the result size, and the applied scale
    func fill(in size: CGSize) -> (CGSize, CGFloat) {
        if width == 0 || height == 0 { return (.zero, 0) }

        var scale = size.width / width
        let newHeight = height * scale
        if newHeight < size.height {
            scale = size.height / height
        }
        let out = CGSize(width: width * scale, height: height * scale)
        return (out, scale)
    }
}

// MARK: - Point utilities -

public extension CGPoint {

    /// Returns a rect of given size, centered on self
    func centeredRect(size: CGSize) -> CGRect {
        return CGRect(x: x - size.width / 2, y: y - size.height / 2, width: size.width, height: size.height)
    }
    
    /// Returns a rect fitting a circle of given ray, centered on self
    func centeredRect(ray: CGFloat) -> CGRect {
        return CGRect(x: x - ray, y: y - ray, width: ray * 2, height: ray * 2)
    }

    /// Returns distance to origin
    var hypo: CGFloat {
        return sqrt( x * x + y * y ) / 2
    }
}

// MARK: - Point/Size/NSNumbers conversions

public extension CGPoint {
    
    /// Converts to size
    var toSize: CGSize { return CGSize(width: x, height: y)}

    /// returns coordinates as numbers
    var asNumbers: (NSNumber, NSNumber) {
        return (NSNumber(value: Double(x)), NSNumber(value: Double(y)))
    }
}

public extension CGSize {
    
    /// Converts to point
    var toPoint: CGPoint { return CGPoint(x: width, y: height)}

    /// returns dimensions as numbers
    var asNumbers: (NSNumber, NSNumber) {
        return (NSNumber(value: Double(width)), NSNumber(value: Double(height)))
    }
}

#endif
