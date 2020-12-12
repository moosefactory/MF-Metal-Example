//
//  ActionProtocol.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

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

/// ParameterProtocol is an Action that change parameters
///
/// - value is a transient property that is used to transport value from control to parameter
/// - min, max and default are values that will be used to build control
protocol ParameterProtocol: ActionIdentifierProtocol {
    
    var min: Any { get set }
    var max: Any { get set }
    var `default`: Any { get set }
}

extension Array where Element == Any &  ActionIdentifierProtocol {
    func with(tag: Int) -> ActionIdentifierProtocol? {
        return first { $0.tag == tag }
    }
}
