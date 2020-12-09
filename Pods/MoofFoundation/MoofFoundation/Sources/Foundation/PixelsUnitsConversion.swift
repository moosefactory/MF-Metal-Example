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

//  PixelsUnitsConversion.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 07/12/2020.

#if !os(watchOS)

import Foundation
import QuartzCore

#if os(macOS)
import Cocoa
#endif

// MARK: - Milimeters/Inches <-> Pixels

public extension CGFloat {
    
    var milimetersToInches: CGFloat {
        return self / 25.4
    }
    
    var inchesToMilimeters: CGFloat {
        return self * 25.4
    }
    
    #if os(macOS)

    func milimetersToPixels(res: CGFloat = 72) -> CGFloat {
        return self.milimetersToInches * NSScreen.screenRes
    }
    
    var milimetersToScreenPixels: CGFloat {
        return self.milimetersToInches * NSScreen.screenRes
    }
    #endif
}

public extension CGSize {
    var milimetersToInches: CGSize {
        return CGSize(width: width.milimetersToInches, height: height.milimetersToInches)
    }
        
    #if os(macOS)
    
    func milimetersToPixels(res: CGFloat = 72) -> CGSize {
        return CGSize(width: width.milimetersToPixels(res: res), height: height.milimetersToPixels(res: res))
    }

    var milimetersToScreenPixels: CGSize {
        return CGSize(width: width.milimetersToScreenPixels, height: height.milimetersToScreenPixels)
    }
    #endif

}

public extension CGPoint {
    
    var milimetersToInches: CGPoint {
        return CGPoint(x: x.milimetersToInches, y: y.milimetersToInches)
    }

    #if os(macOS)
    
    func milimetersToPixels(res: CGFloat = 72) -> CGPoint {
        return CGPoint(x: x.milimetersToPixels(res: res), y: y.milimetersToPixels(res: res))
    }
    
    var milimetersToScreenPixels: CGPoint {
        return CGPoint(x: x.milimetersToScreenPixels, y: y.milimetersToScreenPixels)
    }
    
    #endif
}

#endif
