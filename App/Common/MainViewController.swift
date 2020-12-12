//
//  MainViewController.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 12/12/2020.
//

import Foundation

#if os(macOS)

import Cocoa

typealias MainViewController = MacOSViewController

typealias MFNib = NSNib

extension MFNib {
    static func load(nibNamed name: String, bundle bundleOrNil: Bundle?) -> MFNib {
        return NSNib(nibNamed: name, bundle: bundleOrNil)!
    }
}

typealias MFStackView = NSStackView
typealias MFBox = NSBox
typealias MFControl = NSControl
typealias MFView = NSView
typealias MFOrientation = NSUserInterfaceLayoutOrientation
typealias MFButton = NSButton

extension NSView {
    var viewLayer: CALayer {
        wantsLayer = true
        return layer!
    }
}

extension NSTextField {
    var text: String? {
        get { stringValue }
        set { stringValue = newValue  ?? ""}
    }
}

class MFLabel: NSTextField {
    convenience init(text: String) {
        self.init(labelWithString: text)
    }
}

#else

import UIKit

typealias MainViewController = iOSViewController

typealias MFNib = UINib

extension MFNib {
    static func load(nibNamed name: String, bundle bundleOrNil: Bundle?) -> MFNib {
        return UINib(nibName: name, bundle: bundleOrNil)
    }
}

typealias MFStackView = UIStackView
typealias MFBox = UIView
typealias MFControl = UIControl
typealias MFView = UIView
typealias MFOrientation = NSLayoutConstraint.Axis
typealias MFButton = UIButton

extension UIView {
    var viewLayer: CALayer { layer }
}

class MFLabel: UILabel {
    var stringValue: String? {
        get { text }
        set { text = newValue }
    }
    
    init(text: String?) {
        super.init(frame: .zero)
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIStackView {
    var orientation: MFOrientation {
        get { axis }
        set { axis = newValue }
    }
}

extension UIButton {
    
    convenience init(title: String, target: AnyObject?, action: Selector) {
        self.init(type: .custom)
        setTitle(title, for: .normal)
        addTarget(target, action: action, for: .touchUpInside)
    }
}

extension UISwitch {
    
    convenience init(target: AnyObject?, action: Selector) {
        self.init()
        addTarget(target, action: action, for: .touchUpInside)
    }
}

extension UIControl {
    
    var doubleValue: Double {
        get {
            switch self {
            case is UISlider:
                return Double((self as! UISlider).value)
            default:
                return 0
            }
        }
        set {
            switch self {
            case is UISlider:
                (self as! UISlider).value = Float(newValue)
            default:
                break
            }
        }
    }
    
    var integerValue: Int {
        get { return Int(doubleValue) }
        set { doubleValue = Double(newValue) }
    }
    
    var on: Bool {
        switch self {
        case is UISwitch:
            return (self as! UISwitch).isOn
        default:
            return false
        }
    }
}

extension UISlider {
    
    convenience init(target: AnyObject?, action: Selector) {
        self.init()
        addTarget(target, action: action, for: .touchDragInside)
    }
    
    var minValue: Double {
        get { Double(minimumValue) }
        set { minimumValue = Float(newValue) }
    }
    
    var maxValue: Double {
        get { Double(maximumValue) }
        set { maximumValue = Float(newValue) }
    }
}

#endif
