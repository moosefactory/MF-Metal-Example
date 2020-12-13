//
//  ActionProtocol.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation
import QuartzCore

#if os(macOS)
import Cocoa
#endif

// MARK: - Actions arrays utilities

/// User actions objects must conform to ActionProtocol
///
/// It is a good way to organise actions user can do in the app.
///
/// Actions have a string identifier, an integer tag to map controls, and a control type
/// to determine what kind of control should be created in the UI

protocol ActionIdentifierProtocol {
    var identifier: String { get }
    var tag: Int { get }
    
    var controlType: ActionControlType { get }
}

/// ActionControlType is used to create actions control in the UI.
///
/// At this level, we don't introduce any notion of control class, to stay cross platform.
enum ActionControlType {
    case button
    case `switch`
    case slider
}

extension ActionIdentifierProtocol {
    var title: String { return identifier.localized(table: "Actions") }
}

extension Array where Element == Any & ActionIdentifierProtocol {
    func with(tag: Int) -> ActionIdentifierProtocol? {
        return first { $0.tag == tag }
    }
}

/// ParameterIdentifierProtocol extends ActionIdentifierProtocol by adding min, max and default values
///
/// These values have no type, because we can't add generic constraints to enums

protocol ParameterIdentifierProtocol: ActionIdentifierProtocol {
    var min: Double { get }
    var max: Double { get }
    var `default`: Double { get }
    #if os(macOS)
    func makeSetParameterAction(from control: NSControl) -> TypeErasedSetParameterActionProtocol
    #endif
}

// MARK: - Parameters Objects

/// We use TypeErasedParameterProtocol to store values sent by controls
/// We won't be able to cast ParameterProtocol, since they have an associated type
protocol TypeErasedSetParameterActionProtocol {
    var identifier: ParameterIdentifierProtocol { get set }
    
    var typeErasedValue: Any? { get }
    var stringValue: String { get }
}

extension TypeErasedSetParameterActionProtocol {
    var cgFloat: CGFloat { return CGFloat(typeErasedValue as? Double ?? 0)}
    var double: Double { return typeErasedValue as? Double ?? 0}
    var int: Int { return typeErasedValue as? Int ?? 0 }
    var bool: Bool { return typeErasedValue as? Bool ?? false }
}

/// ParameterProtocol is an Action that change parameters
///
/// - value is a transient property that is used to transport value from control to parameter
/// - min, max and default are values that will be used to build control
protocol SetParameterActionProtocol: TypeErasedSetParameterActionProtocol {
    associatedtype ValueType
    
    var value: ValueType { get set }
    var min: ValueType? { get set }
    var max: ValueType? { get set }
    var `default`: ValueType? { get set }
}

struct SetParameterAction<T>: SetParameterActionProtocol {
    
    var stringValue: String {
        switch value {
        case is CGFloat:
            return "\((value as! CGFloat).dec3)"
        case is Double:
            return "\((value as! Double).dec3)"
        case is Int:
            return "\((value as! Int))"
        case is Bool:
            return "\((value as! Bool) ? "Yes".localized : "No".localized)"
        default:
            return "\(value)"
        }
    }
    
    typealias ValueType = T

    var identifier: ParameterIdentifierProtocol

    var typeErasedValue: Any? { return value }
    var value: T
    var min: T?
    var max: T?
    var `default`: T?
    
    init(identifier: ParameterIdentifierProtocol, value: T) {
        self.identifier = identifier
        self.value = value
        self.min = identifier.min as? T
        self.max = identifier.max as? T
        self.default = identifier.default as? T
    }
}
