//
//  MacOSViewController+UIFactory.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

extension MacOSViewController {
    
    func loadControls() {
        /// Create the main buttons box
        
        ActionsBox.load(in: controlBox.stack, title: "Actions".localized,
                        orientation: .horizontal,
                        with: ActionIdentifier.allCases) { action, control in
            if let appAction = action as? ActionIdentifier {
                self.executeAppAction(appAction)
            }
        }
        
        let paramControlsBox = BoxStackView.load(in: parametersView.stack, title: "", orientation: .horizontal)
        
        /// Create the parameterss box
        let switchesView = ActionsBox.load(in: paramControlsBox.stack,
                                         title: "", labelOnLeft: false,
                                         with: ParameterIdentifier.switches) { action, control in
            if let appAction = action as? ParameterIdentifier {
                let setParamAction = appAction.makeSetParameterAction(from: control)
                self.executeParameterAction(setParamAction)
            }
        }
        
        switchesView.stack.alignment = .left
        switchesView.width = 160

        paramControlsBox.stack.addArrangedSubview(selectedParameterView)
        
        /// Create the parameterss box
        let slidersView = ActionsBox.load(in: paramControlsBox.stack,
                                         title: "", labelOnLeft: true,
                                         with: ParameterIdentifier.sliders) { action, control in
            if let appAction = action as? ParameterIdentifier {
                let setParamAction = appAction.makeSetParameterAction(from: control)
                self.executeParameterAction(setParamAction)
            }
        }
        slidersView.stack.alignment = .right

    }
}
