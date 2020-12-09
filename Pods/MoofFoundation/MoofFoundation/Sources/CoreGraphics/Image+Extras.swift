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

//  Image+Extras.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 07/12/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

#if os(macOS)
import Cocoa
#endif

// MARK: - Images

public extension CGImage {

    var size: CGSize {
        return CGSize(width: width, height: height)
    }
}

#if os(macOS)


public extension CGImage {
    
    var nsImage: NSImage {
        return NSImage(cgImage: self, size: size)
    }
}

public extension NSImage {

    func cgImage() throws -> CGImage {
        var rect = bounds
        guard let cgImage = self.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
            throw BitmapUtils.Errors.cantMakeCGImageFromNSImage
        }
        return cgImage
    }
    
    func bitmap() throws -> CGContext  {
        let bitmap = try BitmapUtils.createBitMap(size: size)
        let cg = try cgImage()
        let rect = bounds
        bitmap.draw(cg, in: rect, byTiling: false)
        return bitmap
    }
    
    var bounds: CGRect {
        return CGRect(origin: .zero, size: size)
    }
    
    func jpegData(quality: CGFloat = 0.5) throws -> Data {
        let cg = try cgImage()
        let bitmapRep = NSBitmapImageRep(cgImage: cg)
        guard let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg,
                                                      properties: [NSBitmapImageRep.PropertyKey.compressionFactor :  NSNumber(value: Double(quality))]) else {
                                                        throw BitmapUtils.Errors.cantGenerateJPEGData
        }
        return jpegData
    }
}

#endif

#endif // watch
