//
//  Actions.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import MoofFoundation

/// Main application ( displayed in the top buttons bar ) actions are defined here
///
/// Actions are Int enums, so they can get mapped to control tags in the UI

/// User actions that control application parameters
enum ActionIdentifier: Int, CaseIterable {
    
    /// showHideMetalView : Show or hide the gravity fields renderer ( Metal View ).
    case showHideFields = 10
        
    /// showHideControls : Show or hide the controls view.
    case showHideControls = 12
    
    /// randomize : Recreate random attractors.
    case randomize = 13
}

extension ActionIdentifier: ActionIdentifierProtocol {
    
    var identifier: String {
        switch self {
        case .showHideFields:
            return "ShowHideFields"
        case .showHideControls:
            return "ShowHideControls"
        case .randomize:
            return "Randomize"
        }
    }
    
    var tag: Int { rawValue }
    
    var controlType: ActionControlType { return .button }
}
