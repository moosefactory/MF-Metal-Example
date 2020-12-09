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

//  Slider.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 05/12/2020.

import Foundation

#if os(macOS)

import Cocoa

class Slider: NSSlider {
    var mouseDownClosure: ((Slider, NSEvent)->Void)?
    var mouseUpClosure: ((Slider, NSEvent)->Void)?

    var initialValue: Double = 0
    
    override func sendAction(_ action: Selector?, to target: Any?) -> Bool {
        let result = super.sendAction(action, to: target)
        
        if let event = NSApplication.shared.currentEvent {
            switch event.type {
            case .leftMouseUp:
                mouseUpClosure?(self, event)
            case .leftMouseDown:
                mouseDownClosure?(self, event)
            default:
                break
            }
        }
        return result
    }
    
    override func mouseDown(with event: NSEvent) {
        initialValue = self.doubleValue
        super.mouseDown(with: event)
    }
}

#endif
