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
        
    @IBOutlet var controlBox: BoxStackView!
    
    @IBOutlet var appActionButtons: NSBox!

    @IBOutlet var fpsLabel: NSTextField!
    @IBOutlet var attractorsLabel: NSTextField!
    
    @IBOutlet var controlsView: BoxStackView!
    @IBOutlet var parametersView: BoxStackView!
    @IBOutlet var selectedParameterView: ParameterView!

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
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadControls()
        
        view.layer?.backgroundColor = CGColor(red: 0.25, green: 0, blue: 0, alpha: 1)

        makeGravityFieldsView()
        makeParticlesView()
    }
    
    func makeGravityFieldsView() {
        // Creates the Metal view under the controls box
        mtkView = GraviFieldsView( frame: view.bounds, world: worldBuffers)
        view.addSubview(mtkView, positioned: NSWindow.OrderingMode.below, relativeTo: controlsView)
        mtkView.autoresizingMask = [.width, .height]
        //mtkView.delegate = self // Not working... Wonder why
        mtkView.renderedClosure = { frameIndex in
            self.tick()
        }
    }
    
    func makeParticlesView() {
        // Creates the Particles view between the metal view and the controls box
        particlesView = ParticlesView(frame: view.bounds, world: worldBuffers)
        view.addSubview(particlesView, positioned: NSWindow.OrderingMode.above, relativeTo: mtkView)
        particlesView.autoresizingMask = [.width, .height]
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
        
    func updateFPS() {
        let elapsedTime = -chrono.timeIntervalSinceNow
        chrono = Date()
        // Use low pass filter to avoid rapid value changes
        let nonFilteredFPS = 1 / elapsedTime
        fps = (0.05 * nonFilteredFPS) + (0.95 * fps)
        fpsLabel.stringValue = "\(Int(fps))"
    }
}
