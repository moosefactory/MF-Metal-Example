//
//  ActionProtocol+Controls.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import MoofFoundation

#if os(macOS)
import Cocoa
#endif

extension ActionIdentifierProtocol {
    
    func makeControl(target: AnyObject?, action: Selector?) -> NSControl {
        switch controlType {
        case .button:
            return NSButton(title: title, target: target, action: action)
        case .switch:
            return NSSwitch(target: target, action: action)
        case .slider:
            let slider = NSSlider(target: target, action: action)
            if let param = self as? ParameterIdentifierProtocol {
                slider.minValue = param.min
                slider.maxValue = param.max
                slider.doubleValue = param.default
            }
            slider.width = 100
            return slider
        }
    }
}

extension ParameterIdentifier {
    func makeSetParameterAction(from control: NSControl) -> TypeErasedParameterProtocol {
        switch self {
        case .setNumberOfAttractors, .setSpringForce, .setMinDistance, .setExponent, .setScale:
            let value = control.doubleValue
            return SetParameterAction<Double>(identifier: self, value: value)
        case .setParticlesGridSize:
            let value = control.integerValue
            return SetParameterAction<Int>(identifier: self, value: value)
        default:
            let value = control.isOn
            return SetParameterAction<Bool>(identifier: self, value: value)
        }
    }
}
