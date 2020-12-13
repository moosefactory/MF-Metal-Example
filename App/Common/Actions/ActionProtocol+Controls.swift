//
//  ActionProtocol+Controls.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import MoofFoundation

#if os(macOS)
import Cocoa

extension ActionIdentifierProtocol {
    
    func makeControl(target: AnyObject?, action: Selector?) -> MFControl {
        switch controlType {
        case .button:
            return NSButton(title: title, target: target, action: action)
        case .switch:
            let control = NSSwitch(target: target, action: action)
            if let param = self as? ParameterIdentifierProtocol {
                control.doubleValue = param.default
            }
            return control
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

#else

import UIKit

extension ActionIdentifierProtocol {
    
    func makeControl(target: AnyObject?, action: Selector) -> MFControl {
        switch controlType {
        case .button:
            return UIButton(title: title, target: target, action: action)
        case .switch:
            let control = UISwitch(target: target, action: action)
            if let param = self as? ParameterIdentifierProtocol {
                control.isOn = param.default > 0
            }
            return control
        case .slider:
            let slider = UISlider(target: target, action: action)
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

#endif


extension ParticlesParametersIdentifier {
    func makeSetParameterAction(from control: MFControl) -> TypeErasedSetParameterActionProtocol {
        switch self {
        case .setSpringForce, .setParticlesSensitivity:
            let value = control.doubleValue
            return SetParameterAction<Double>(identifier: self, value: value)
        case .setParticlesGridSize:
            let value = control.integerValue
            return SetParameterAction<Int>(identifier: self, value: value)
        default:
            let value = control.on
            return SetParameterAction<Bool>(identifier: self, value: value)
        }
    }
}

extension FieldsParametersIdentifier {
    func makeSetParameterAction(from control: MFControl) -> TypeErasedSetParameterActionProtocol {
        switch self {
        case .setFieldsSensitivity, .setMinDistance, .setExponent, .setGravity, .setScale:
            let value = control.doubleValue
            return SetParameterAction<Double>(identifier: self, value: value)
        case .setComplexity:
            let value = control.integerValue
            return SetParameterAction<Int>(identifier: self, value: value)
        default:
            let value = control.on
            return SetParameterAction<Bool>(identifier: self, value: value)
        }
    }
}
