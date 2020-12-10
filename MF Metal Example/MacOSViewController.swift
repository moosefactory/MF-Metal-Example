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
        case showHideControls = 103
        case lockOnGrid = 110
    }
    
    enum SliderAction: Int {
        case setNumberOfAttractors = 100
        case setNumberOfParticles = 101
        
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
    
    @IBOutlet var controlsView: NSStackView!
    
    var mtkView: GraviFieldsView!
    var particlesView: ParticlesView!
    
    var chrono = Date()
    var fps: Double = 0
    
    // The world, contains particles, attractors, and environment variables
    var world = World()
    
    // The world adapted to GPU - it basically holds raw buffers with world element,
    // and adds the notion of time and space ( Renderer size and frame index )
    lazy var worldBuffers: WorldBuffers = {
        return WorldBuffers(world: world, for: MTLCreateSystemDefaultDevice()!)
    }()
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        mtkView.calculator = nil
    }
    
    func draw(in view: MTKView) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeGravityFieldsView()
        makeParticlesView()
    }
    
    func makeGravityFieldsView() {
        // Creates the Metal view under the controls box
        mtkView = GraviFieldsView( frame: view.bounds, world: worldBuffers)
        view.addSubview(mtkView, positioned: NSWindow.OrderingMode.below, relativeTo: controlBox)
        mtkView.autoresizingMask = [.width, .height]
        //mtkView.delegate = self // Not working... Wonder why
        mtkView.renderedClosure = { frameIndex in
            self.tick()
        }
    }
    
    func makeParticlesView() {
        // Creates the Particles view between the metal view and the controls box
        particlesView = ParticlesView(frame: view.bounds, world: worldBuffers)
        view.addSubview(particlesView, positioned: NSWindow.OrderingMode.below, relativeTo: controlBox)
        view.layer?.backgroundColor = CGColor(red: 0.5, green: 0, blue: 0, alpha: 0.5)
        particlesView.autoresizingMask = [.width, .height]
    }
    
    @IBAction func buttonTapped(_ sender: NSButton) {
        guard let action = Action(rawValue: sender.tag) else { return }
        switch action {
        case .showHideMetalView:
            mtkView.isHidden = !mtkView.isHidden
        case .showHideAttractors:
            particlesView.isHidden = !particlesView.isHidden
            break
        case .randomize:
            randomize()
        case .showHideControls:
            controlsView.isHidden = !controlsView.isHidden
        case .lockOnGrid:
            world.lockParticles = sender.state == NSControl.StateValue.on
        }
        
        // Since we hide the metal view, the rendered closure won't be called anymore, so we start our timer to continue update particles if needed.
        if mtkView.isHidden && !particlesView.isHidden {
            startTimer()
        }
        else {
            stopTimer()
        }
    }
    
    var timer: Timer?
    
    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1 / 60, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func tick() {
        
        func finishUpdate() {
            if world.updateFlag.contains(.attractors) {
                attractorsLabel.stringValue = "\(Int(world.objects.attractors.count))"
            }
            self.updateFPS()
            if !world.updateFlag.isEmpty { world.updateFlag = [] }
        }
        
        guard !particlesView.isHidden else {
            finishUpdate()
            return
        }
        // If metal view is  hidden, we update position and frame index here // TO CHANGE
        if mtkView.isHidden {
            self.worldBuffers.createOrUpdateBuffers()
            self.worldBuffers.frameIndex += 1
        }
        
        self.particlesView.update() { }
        finishUpdate()
    }
    
    @IBAction func sliderChanged(_ sender: NSSlider) {
        guard let action = SliderAction(rawValue: sender.tag) else { return }
        switch action {
        case .setNumberOfAttractors:
            world.complexity = Int(sender.intValue)
        case .setNumberOfParticles:
            world.numberOfParticles = Int(sender.intValue)
        case .setExponent:
            world.gravityExponent = CGFloat(sender.doubleValue / 10)
        case .setMinDistance:
            world.minimalDistance = CGFloat(sender.doubleValue / 10)
        case .setScale:
            world.gravityFactor = CGFloat(sender.doubleValue / 10)
        }
    }
    
    /// Recreate random attractors
    func randomize() {
        world.randomize()
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
