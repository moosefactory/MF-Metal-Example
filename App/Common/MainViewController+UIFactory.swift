//
//  MainViewController+UIFactory.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

extension MainViewController {
    
    func loadControls() {
        
        // 1 ---  Create the main buttons box
        // A simple horizontal box containing main buttons
 
        ActionsBox.loadBox(in: uiContainer, style: .main, title: "Actions".localized,
                           orientation: .horizontal,
                           with: ActionIdentifier.allCases) { action, control in
            if let appAction = action as? ActionIdentifier {
                self.executeAppAction(appAction)
            }
        }
        
        // 2 ---  Create the parameters controls box under the buttons box
        // A second horizontal box containing sub-boxes for switches, selected param and sliders

        var orientation: MFOrientation = .horizontal
        #if !os(macOS)
        orientation = .vertical
        #endif
        
        paramControlsBox = ActionsBox.loadBox(in: uiContainer, style: .main, title: "", orientation: orientation)
        
        // <-------- Switches on the left
                
        let switchesView = ActionsBox.loadBox(in: paramControlsBox.stack, style: .sub,
                                              title: "", labelOnLeft: false,
                                              with: ParameterIdentifier.switches) { action, control in
            if let appAction = action as? ParameterIdentifier {
                let setParamAction = appAction.makeSetParameterAction(from: control)
                self.executeParameterAction(setParamAction)
            }
        }
        
        #if os(macOS)
        switchesView.stack.alignment = .left
        #else
        switchesView.stack.alignment = .leading
        #endif

        switchesView.width = 160
        
        //  -----> Selected parameter in middle <-----
        // Move the selectedParameter view ( defined in storyboard ) in the parameters box
        //selectedParameterView.removeFromSuperview()
        //uiContainer.removeArrangedSubview(selectedParameterView)
        #if os(macOS)
        paramControlsBox.stack.addArrangedSubview(selectedParameterView)
        #else

        #endif

        // Sliders on the right -------->
        
        let slidersView = ActionsBox.loadBox(in: paramControlsBox.stack, style: .sub,
                                             title: "", labelOnLeft: true,
                                             with: ParameterIdentifier.sliders) { action, control in
            if let appAction = action as? ParameterIdentifier {
                let setParamAction = appAction.makeSetParameterAction(from: control)
                self.executeParameterAction(setParamAction)
            }
        }
        
        #if os(macOS)
        slidersView.stack.alignment = .right
        #else
        slidersView.stack.alignment = .trailing
        #endif

        
    }
}
