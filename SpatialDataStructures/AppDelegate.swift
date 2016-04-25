/*
 * Copyright (C) 2016 Josh A. Beam
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Cocoa
import OpenGL
import GLKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var staticDataStructurePopUpButton: NSPopUpButton!
    @IBOutlet weak var dynamicDataStructurePopUpButton: NSPopUpButton!
    @IBOutlet weak var numberOfObjectsPopUpButton: NSPopUpButton!
    @IBOutlet weak var view: MyNSOpenGLView!
    @IBOutlet weak var fpsLabel: NSTextField!

    private var timer: NSTimer!
    private var fpsTimer: NSTimer!
    private var scene: Scene!

    private var renderScene: Bool = true
    private var renderTrees: Bool = false
    private var collisionDetection: Bool = true
    
    private var ticks: UInt64 = Util.getTicks()
    private var ticksElapsed: UInt64 = 0

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Util.seedRandom(Int(Util.getTicks() % 1000000))

        // Populate the data structure pop-up buttons.
        staticDataStructurePopUpButton.removeAllItems()
        staticDataStructurePopUpButton.addItemsWithTitles(SpatialTreeFactory.spatialTreeNames)
        staticDataStructurePopUpButton.selectItemWithTitle(SpatialTreeFactory.defaultSpatialTreeName)
        dynamicDataStructurePopUpButton.removeAllItems()
        dynamicDataStructurePopUpButton.addItemsWithTitles(SpatialTreeFactory.spatialTreeNames)
        dynamicDataStructurePopUpButton.selectItemWithTitle(SpatialTreeFactory.defaultSpatialTreeName)
        numberOfObjectsPopUpButton.removeAllItems()
        numberOfObjectsPopUpButton.addItemsWithTitles(SpatialTreeFactory.numbersOfObjects.flatMap({ String($0) }))

        // Do some GL setup.
        glClearColor(0.3, 0.3, 0.4, 1.0)
        glClearDepth(1.0)
        glDisable(GLenum(GL_BLEND))
        glEnable(GLenum(GL_DEPTH_TEST))
        glDepthFunc(GLenum(GL_LEQUAL))
        glDisable(GLenum(GL_CULL_FACE))
        glFrontFace(GLenum(GL_CCW))
        glCullFace(GLenum(GL_BACK))

        scene = Scene()
        dataStructureChanged(nil)

        // Create a timer to render.
        timer = NSTimer(timeInterval: 1.0 / 60.0,
            target: self,
            selector: #selector(AppDelegate.timerFireMethod(_:)),
            userInfo: nil,
            repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)

        // Create a timer to update FPS label.
        fpsTimer = NSTimer(timeInterval: 1.0,
                           target: self,
                           selector: #selector(AppDelegate.fpsTimerFireMethod(_:)),
                           userInfo: nil,
                           repeats: true)
        NSRunLoop.currentRunLoop().addTimer(fpsTimer, forMode: NSDefaultRunLoopMode)
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

    func timerFireMethod(sender: NSTimer!) {
        // Render the scene.
        if renderScene {
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
            scene.render(view.projectionMatrix, renderTrees: renderTrees)
            glFlush()
            view.flush()
        }

        // Cycle the scene.
        let newTicks = Util.getTicks()
        ticksElapsed = newTicks - ticks
        let secondsElapsed = Float(ticksElapsed) / 1000.0
        ticks = newTicks
        scene.cycle(secondsElapsed, collisionDetection)
    }

    func fpsTimerFireMethod(sender: NSTimer!) {
        // Update milliseconds per frame label.
        fpsLabel.stringValue = String(ticksElapsed) + " ms per frame"
    }

    @IBAction func dataStructureChanged(sender: NSPopUpButtonCell?) {
        let staticSpatialTreeName = staticDataStructurePopUpButton.selectedItem!.title
        let dynamicSpatialTreeName = dynamicDataStructurePopUpButton.selectedItem!.title
        let numberOfObjects = Int(numberOfObjectsPopUpButton.selectedItem!.title)!

        scene?.rebuildSpatialTrees(staticSpatialTreeName, dynamicSpatialTreeName, numberOfObjects: numberOfObjects)
    }

    @IBAction func renderSceneChanged(sender: NSButtonCell) {
        renderScene = (sender.integerValue != 0)
    }

    @IBAction func renderTreesChanged(sender: NSButtonCell) {
        renderTrees = (sender.integerValue != 0)
    }

    @IBAction func collisionDetectionChanged(sender: NSButtonCell) {
        collisionDetection = (sender.integerValue != 0)
    }

    func doExportStatistics(url: NSURL) {
        let simulator = Simulator()

        while simulator.numberOfSimulationsCompleted < simulator.numberOfSimulationsToRun {
            simulator.runNextSimulation()
        }

        do {
            try simulator.exportCSV(url)
        } catch {}
    }

    @IBAction func exportStatistics(sender: NSMenuItem) {
        let savePanel = NSSavePanel()
        savePanel.beginSheetModalForWindow(window) { result in
            if result == NSFileHandlingPanelOKButton {
                self.doExportStatistics(savePanel.URL!)
            }
        }
    }
}
