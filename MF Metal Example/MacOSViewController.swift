//
//  ViewController.swift
//  TestMetal
//
//  Created by Tristan Leblanc on 24/11/2020.
//  Copyright © 2020 MooseFactory Software. All rights reserved.
//

import Cocoa
import MetalKit
import MoofFoundation

class MacOSViewController: NSViewController, MTKViewDelegate {
    
    enum Action: Int {
        case showHideMetalView = 100
        case showHideAttractors = 101
        case randomize = 102
    }
    
    enum SliderAction: Int {
        case setMinDistance = 200
        case setExponent = 201
        case setScale = 202
    }
    
    @IBOutlet var controlBox: NSBox!
    @IBOutlet var fpsLabel: NSTextField!
    @IBOutlet var attractorsLabel: NSTextField!

    @IBOutlet var minDistanceSlider: NSSlider!
    @IBOutlet var gExponentSlider: NSSlider!
    @IBOutlet var gFactorSlider: NSSlider!
    
    var mtkView: GraviFieldsView!
    
    var chrono = Date()
    var fps: Double = 0
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Will recreate the texture
        mtkView.calculator = nil
    }
    
    func draw(in view: MTKView) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creates the Metal view under the controls box
        mtkView = GraviFieldsView( frame: view.bounds, device: MTLCreateSystemDefaultDevice()!)
        view.addSubview(mtkView, positioned: NSWindow.OrderingMode.below, relativeTo: controlBox)
        view.layer?.backgroundColor = CGColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        mtkView.autoresizingMask = [.width, .height]
        //mtkView.delegate = self // Not working... Wonder why
        mtkView.renderedClosure = { fraeIndex in
            self.updateFPS()
        }
        randomize()
    }
    
    @IBAction func buttonTapped(_ sender: NSButton) {
        guard let action = Action(rawValue: sender.tag) else { return }
        switch action {
        case .showHideMetalView:
            mtkView.isHidden = !mtkView.isHidden
        case .showHideAttractors:
            break
        case .randomize:
            randomize()
        }
    }
    
    @IBAction func sliderChanged(_ sender: NSSlider) {
        guard let action = SliderAction(rawValue: sender.tag) else { return }
        switch action {
        case .setExponent:
            mtkView.calculator?.gravityExponent = CGFloat(sender.doubleValue / 10)
        case .setMinDistance:
            mtkView.calculator?.minimalDistance = CGFloat(sender.doubleValue / 10)
        case .setScale:
            mtkView.calculator?.gravityFactor = CGFloat(sender.doubleValue / 10)
        }
    }

    /// Recreate random attractors
    func randomize() {
        mtkView.makeWorld()
        updateSettingsFromSliders()
        attractorsLabel.stringValue = "\(Int(mtkView.attractors.count))"
    }
    
    func updateSettingsFromSliders() {
        mtkView.calculator?.gravityExponent = CGFloat(gExponentSlider.doubleValue / 10)
        mtkView.calculator?.minimalDistance = CGFloat(minDistanceSlider.doubleValue / 10)
        mtkView.calculator?.gravityFactor = CGFloat(gFactorSlider.doubleValue / 10)
    }

    func updateFPS() {
        let elapsedTime = -chrono.timeIntervalSinceNow
        chrono = Date()
        // Use low pass filter to avoid rapid value changes
        let nonFilteredFPS = 1 / elapsedTime
        fps = (0.05 * nonFilteredFPS) + (0.95 * fps)
        fpsLabel.stringValue = "\(Int(fps))"
    }
}
