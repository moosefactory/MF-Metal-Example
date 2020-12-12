//
//  MainViewController+Tick.swift
//  MF Metal Example
//
//  Created by Tristan Leblanc on 11/12/2020.
//

import Foundation

extension MainViewController {
    
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
                attractorsLabel?.text = "\(Int(world.objects.attractors.count))"
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
        (1 / elapsedTime).lowPassFilter(value: &fps)
        fpsLabel?.text = "\(Int(fps))"
    }

}
