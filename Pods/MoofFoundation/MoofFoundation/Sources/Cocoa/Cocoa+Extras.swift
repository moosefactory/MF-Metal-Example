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

//  Cocoa+Extras.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 19/11/2020.

import Foundation

#if os(macOS)

import Cocoa

// MARK: - View utilities

/// Operations on all subviews

public extension NSView {
    
    func hideAllSubviews() {
        subviews.forEach { $0.isHidden = true }
    }
    
    func showAllSubviews() {
        subviews.forEach { $0.isHidden = false }
    }
    
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}

/// Snapshot of the view

public extension NSView {
    
    func snapshotImage() -> NSImage {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
    }
}

// MARK: - Stack view utilities

public extension NSStackView {
    
    func removeAllArrangedSubviews() {
        let views = arrangedSubviews
        views.forEach {
            self.removeArrangedSubview($0)
            //self.removeView($0)
        }
    }
}

// MARK: - Controls utilities

public extension NSSlider {
    var percentValue: Float {
        return Float(floatValue) / Float(maxValue)
    }
}

/// Bool to on/off constrol state
public extension Bool {
    var onOff: NSControl.StateValue { return self ? .on : .off }
}

#endif
