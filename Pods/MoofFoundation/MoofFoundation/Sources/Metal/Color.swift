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

//  Color.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 25/11/2020.


#if !os(watchOS)

import Foundation
import QuartzCore

import simd
#if os(macOS)
import Cocoa
#endif

public struct Color: Codable {
    
    public var red: CGFloat = 0
    public var green: CGFloat = 0
    public var blue: CGFloat = 0
    public var alpha: CGFloat = 0
    
    public init() {
        self.red = 0
        self.green = 0
        self.blue = 0
        self.alpha = 1
    }
    
    public init(red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
    }
    
    public static let blue = Color(red: 0, green: 0, blue: 1, alpha: 1)
    public static let red = Color(red: 1, green: 0, blue: 0, alpha: 1)
    public static let green = Color(red: 0, green: 1, blue: 0, alpha: 1)
    public static let yellow = Color(red: 1, green: 1, blue: 0, alpha: 1)
    public static let orange = Color(red: 1, green: 0.5, blue: 0, alpha: 1)
    
    public static let black = Color(red: 0, green: 0, blue: 0, alpha: 1)
    public static let white = Color(red: 1, green: 1, blue: 1, alpha: 1)
    public static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
    
    public static func + (lhs: Color, rhs: Color) -> Color {
        return Color(red: lhs.red + rhs.red, green: lhs.green + rhs.green, blue: lhs.blue + rhs.blue, alpha: lhs.alpha + rhs.alpha)
    }
    
    public static func += (lhs: inout Color, rhs: Color) {
        lhs.red += rhs.red
        lhs.green += rhs.green
        lhs.blue += rhs.blue
        lhs.alpha += rhs.alpha
    }
    
    public static func - (lhs: Color, rhs: Color) -> Color {
        return Color(red: lhs.red - rhs.red, green: lhs.green - rhs.green, blue: lhs.blue - rhs.blue, alpha: lhs.alpha - rhs.alpha)
    }
    
    public static func / (lhs: Color, rhs: Int) -> Color {
        let f = CGFloat(rhs)
        return Color(red: lhs.red / f, green: lhs.green / f, blue: lhs.blue / f, alpha: lhs.alpha / f)
    }
    
    public static func * (lhs: Color, rhs: Int) -> Color {
        let f = CGFloat(rhs)
        return Color(red: lhs.red * f, green: lhs.green * f, blue: lhs.blue * f, alpha: lhs.alpha * f)
    }
    
    public static func baryColor(_ color1: Color, _ color2: Color, fraction: CGFloat = 0.5) -> Color {
        
        return Color(red: color1.red.bary(to: color2.red, fraction: fraction),
                     green: color1.green.bary(to: color2.green, fraction: fraction),
                     blue: color1.blue.bary(to: color2.blue, fraction: fraction),
                     alpha: color1.alpha.bary(to: color2.alpha, fraction: fraction))
    }
    
    public func with(alpha: CGFloat) -> Color {
        return Color(red: red, green: green, blue: blue, alpha: alpha)
    }
}


public extension Color {
    var simd: simd_float4 { return [Float(red), Float(green), Float(blue), Float(alpha)] }
    
    var cgColor: CGColor { return CGColor(srgbRed: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))}
}

extension Color: CustomStringConvertible {
    public var description: String {
        return "r:\(red.dec3) g:\(green.dec3) b:\(blue.dec3) a:\(alpha.dec3) "
    }
}

public extension CGColor {
    var color: Color {
        guard let comps = components else {
            return .black
        }
        let n = numberOfComponents
        switch n {
        // Grayscale
        case 1:
            return Color(red: comps[0], green: comps[0], blue: comps[0], alpha: 1)
        // Grayscale with alpha
        case 2:
            return Color(red: comps[0], green: comps[0], blue: comps[0], alpha: comps[1])
        // RGB
        case 3:
            return Color(red: comps[0], green: comps[1], blue: comps[2], alpha: 1)
        // RGB with alpha
        case 4:
            return Color(red: comps[0], green: comps[1], blue: comps[2], alpha: comps[3])
        default:
            return .black
        }
    }
}

#if os(macOS)

public extension Color {
    
    var hsla: HSLATuplet { nsColor.hsla }
    
    
    var nsColor: NSColor { return NSColor(srgbRed: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha)) }
    
    func with(brightnessFactor: CGFloat) -> Color {
        var hsla = self.hsla
        hsla.l = max(min(hsla.l * brightnessFactor, 1),0)
        let nsColor = NSColor(hsla: hsla)
        return nsColor.color
    }
    
    
    public var darken: Color {
        return with(brightnessFactor: 0.50)
    }
    
    public var lighten: Color {
        return with(brightnessFactor: 2)
    }
    
    /// Returns a black or white color that is visible on a background of given color
    public static func visibleColor(on color: Color) -> Color {
        let brightness = color.hsla.l
        return brightness < 0.35 ? .white : .black
    }
    

}

public extension NSColor {
    var color: Color {
        return Color(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
    }
}

#endif

#endif
