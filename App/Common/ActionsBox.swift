//
//  ActionsBox.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import MoofFoundation
import SnapKit

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class ActionsBox: MFBox, NibView {
    
    enum Style {
        case main
        case sub
        case clear
    }
    
    @IBOutlet weak var stack: MFStackView!

    var margin: CGFloat = 10 { didSet {
        updateMargin()
    }}
    
    var actionClosure: ((ActionIdentifierProtocol?, MFControl)->Void)?
    var actions: [ActionIdentifierProtocol]?
    
    var style: Style = .main {
        didSet {
            switch style {
            case .main:
                viewLayer.backgroundColor = Color.black.with(alpha: 0.6).cgColor
                viewLayer.borderColor = Color.white.with(alpha: 0.5).cgColor
                viewLayer.cornerRadius = 6
                viewLayer.borderWidth = 2
                margin = 10
            case .sub:
                viewLayer.backgroundColor = Color.black.with(alpha: 0.1).cgColor
                viewLayer.borderColor = Color.clear.cgColor
                viewLayer.cornerRadius = 5
                viewLayer.borderWidth = 2
                margin = 5
            case .clear:
                viewLayer.backgroundColor = Color.clear.cgColor
                viewLayer.borderColor = Color.clear.cgColor
                viewLayer.cornerRadius = 0
                viewLayer.borderWidth = 0
                margin = 0
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        updateMargin()
    }
    
    func updateMargin() {
        stack.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(margin)
        }
    }
    
    /// Loads an actions box without actions
    ///
    /// In this case the view is aligne horizontally by default, and used only to display subviews in a box
    
    @discardableResult static func loadBox(in view: MFView, style: Style = .main,
                                        title: String = "",
                                        orientation: MFOrientation = .horizontal) -> ActionsBox {
        let box = Self.load(in: view)
        box.stack.orientation = orientation
        //box.stack.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: .horizontal)
        box.style = style
        return box
    }
    
    /// Loads an actions box
    ///
    /// Actions and closure are optionals
    @discardableResult static func loadBox(in view: MFView, style: Style = .main, title: String = "",
                                        orientation: MFOrientation = .vertical,
                                        labelOnLeft: Bool = true,
                                        with actions: [ActionIdentifierProtocol],
                                        actionClosure: @escaping (ActionIdentifierProtocol?, MFControl)->Void) -> ActionsBox {
        let box = Self.loadBox(in: view, style: style, title: title, orientation: orientation)
        
        actions.forEach {
            let control = $0.makeControl(target: box, action: #selector(controlChanged))
            control.tag = $0.tag
            var title = $0.title
            if control is MFButton {
                title = ""
            }
            var orientation: MFOrientation = .horizontal
            #if !os(macOS)
            orientation = control is UISlider ? .vertical : .horizontal
            (control as? UIButton)?.titleLabel?.font = UIFont.systemFont(ofSize: 11)
            //(control as? UISlider)?.isContinuous = true
            #endif

            let controlBox = ActionsBox.loadWithControl(in: box.stack,
                                                        style: .clear,
                                                        title: title,
                                                        orientation: orientation,
                                                        labelOnLeft: labelOnLeft,
                                                        with: control)
            controlBox.stack.spacing = 3
        }
        
        box.stack.orientation = orientation
        //box.stack.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: .horizontal)
        box.actions = actions
        box.actionClosure = actionClosure
        
        return box
    }

    @objc func controlChanged(sender: MFControl) {
        guard let action = actions?.with(tag: sender.tag) else { return }
        actionClosure?(action, sender)
    }
}

extension ActionsBox {
    
    @discardableResult static func loadWithControl(in view: MFView, style: Style = .main, title: String = "",
                                        orientation: MFOrientation = .horizontal,
                                        labelOnLeft: Bool = true,
                                        with control: MFControl) -> ActionsBox {
        let box = ActionsBox.load(in: view)
        box.style = style
        box.stack.orientation = orientation
        #if os(macOS)
        box.stack.alignment = .centerY
        #else
        box.stack.alignment = .center
        #endif
        if !title.isEmpty {
            let label = MFLabel(text: title)
            #if os(macOS)

            #else
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 11)
            #endif

            box.stack.addArrangedSubview(label)
        }
        if labelOnLeft {
            box.stack.addArrangedSubview(control)
        } else {
            box.stack.insertArrangedSubview(control, at: 0)
        }
        return box
    }
}
