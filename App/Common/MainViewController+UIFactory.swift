//
//  MainViewController+UIFactory.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

extension MainViewController {
    
    enum ControlsCategory {
        case fields
        case particles
    }
    
    // 1 ---  Create the main buttons box
    // A simple horizontal box containing main buttons
    
    func loadMainControls() {
        
        ActionsBox.loadBox(in: uiContainer, style: .main, title: "Actions".localized,
                           orientation: .horizontal,
                           with: ActionIdentifier.allCases) { action, control in
            if let appAction = action as? ActionIdentifier {
                self.executeAppAction(appAction)
            }
        }
        
        loadParticlesControls()
        loadFieldsControls()
    }
    
    // 2 ---  Create the parameters controls box under the buttons box
    // A second horizontal box containing sub-boxes for switches, selected param and sliders
    
    func loadParticlesControls() {
        
        var orientation: MFOrientation = .horizontal
        #if !os(macOS)
        orientation = .vertical
        #endif
        
        particlesParamControlsBox = ActionsBox.loadBox(in: uiContainer, style: .main, title: "", orientation: orientation)
        
        // <-------- Switches on the left
        
        let switchesView = ActionsBox.loadBox(in: particlesParamControlsBox.stack, style: .sub,
                                              title: "", labelOnLeft: false,
                                              with: ParticlesParametersIdentifier.switches) { action, control in
            if let appAction = action as? ParticlesParametersIdentifier {
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
        particlesParamControlsBox.stack.addArrangedSubview(selectedParameterView)
        #else
        
        #endif
        
        // Sliders on the right -------->
        
        let slidersView = ActionsBox.loadBox(in: particlesParamControlsBox.stack, style: .sub,
                                             title: "", labelOnLeft: true,
                                             with: ParticlesParametersIdentifier.sliders) { action, control in
            if let appAction = action as? ParticlesParametersIdentifier {
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
    
    
    // 2 ---  Create the parameters controls box under the buttons box
    // A second horizontal box containing sub-boxes for switches, selected param and sliders
    
    func loadFieldsControls() {
        
        var orientation: MFOrientation = .horizontal
        #if !os(macOS)
        orientation = .vertical
        #endif
        
        fieldsParamControlsBox = ActionsBox.loadBox(in: uiContainer, style: .main, title: "", orientation: orientation)
        
        // <-------- Switches on the left
        
        let switchesView = ActionsBox.loadBox(in: fieldsParamControlsBox.stack, style: .sub,
                                              title: "", labelOnLeft: false,
                                              with: FieldsParametersIdentifier.switches) { action, control in
            if let appAction = action as? FieldsParametersIdentifier {
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
        fieldsParamControlsBox.stack.addArrangedSubview(selectedParameterView)
        #else
        
        #endif
        
        // Sliders on the right -------->
        
        let slidersView = ActionsBox.loadBox(in: fieldsParamControlsBox.stack, style: .sub,
                                             title: "", labelOnLeft: true,
                                             with: FieldsParametersIdentifier.sliders) { action, control in
            if let appAction = action as? FieldsParametersIdentifier {
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
