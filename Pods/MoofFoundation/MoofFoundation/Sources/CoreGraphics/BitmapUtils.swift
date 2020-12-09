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

//  Bitmap.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 18/11/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

public struct BitmapUtils {
    
    public enum Errors: String, Error {
        case cantCreateZeroSizeBitmap
        case notEnoughMemoryToCreateBitmap
        // To use when trying to make a bitmap from an NSImage
        case cantMakeCGImageFromNSImage
        // To use when trying to create jpeg data representation
        case cantGenerateJPEGData
    }
    
    public static func createBitMap(size: CGSize) throws -> CGContext {
        guard Int(size.width) >= 1 && Int(size.height) >= 1 else {
            throw Errors.cantCreateZeroSizeBitmap
        }

        let cs = CGColorSpaceCreateDeviceRGB()

        let bitmap = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(size.width), space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        if bitmap == nil {
            throw Errors.notEnoughMemoryToCreateBitmap
        }
        
        return bitmap!
    }
}

public typealias RawRGBA = (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
public typealias RawScanParameters = (Int, Int)->RawRGBA
public typealias ScanParameters = (CGPoint, inout Any?, CGAffineTransform)->RawRGBA

public extension CGContext {
        
    func rawScan(componentsGenerator: RawScanParameters) {
        for y in 0..<height {
            for x in 0..<width {
                setColorComponents(x: x, y: y, components: componentsGenerator(x,y))
            }
        }
    }
    
    func scan(ctm: CGAffineTransform, userInfo: inout Any?, componentsGenerator: ScanParameters) {
        for y in 0..<height {
            for x in 0..<width {
                let p = CGPoint(x: x, y: y).applying(ctm)
                setColorComponents(x: x, y: y, components: componentsGenerator(p, &userInfo, ctm))
            }
        }
    }
    
    func scanTile(_ tile: Tile, userInfo: inout Any?, ctm: CGAffineTransform, componentsGenerator: ScanParameters) {
        for y in tile.minY..<tile.maxY {
            for x in tile.minX..<tile.maxX {
                let p = CGPoint(x: x, y: y).applying(ctm)
                setColorComponents(x: x, y: y, components: componentsGenerator(p, &userInfo, ctm))
            }
        }
    }

    func colorComponents(x: Int, y: Int) -> (RawRGBA)? {
        guard  0<=x && x<width, 0<=y && y<height else { return nil }
        guard let uncasted_data = self.data else { return nil }
        let data: UnsafeMutablePointer<UInt8> = uncasted_data.assumingMemoryBound(to: UInt8.self)
        let offset = 4 * (y * width + x)
        return RawRGBA(r: data[offset], g: data[offset+1], b: data[offset+2], a: data[offset+3])
    }

    
    func setColorComponents(x: Int, y: Int, components: RawRGBA) {
        guard  0<=x && x<width, 0<=y && y<height else { return }
        guard let uncasted_data = self.data else { return }
        let data: UnsafeMutablePointer<UInt8> = uncasted_data.assumingMemoryBound(to: UInt8.self)
        let offset = 4 * (y * width + x)
        data[offset] = components.r
        data[offset+1] = components.g
        data[offset+2] = components.b
        data[offset+3] = components.a
    }
}

#endif
