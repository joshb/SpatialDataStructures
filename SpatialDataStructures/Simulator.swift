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

import Foundation

/// Runs simulations with various combinations of spatial
/// data structures and numbers of objects.
class Simulator {
    private typealias SimulationResults = (staticDataStructureName: String,
                                           dynamicDataStructureName: String,
                                           numberOfObjects: Int,
                                           averageMillisecondsPerFrame: Int)

    private var results: [SimulationResults] = []

    private var staticDataStructureIndex = 0
    private var dynamicDataStructureIndex = 0
    private var numberOfObjectsIndex = 0

    var framesPerSimulation: UInt64 = 4
    var timeStep: Float = 1.0 / 30.0

    var nextStaticDataStructureName: String? {
        let names = SpatialTreeFactory.spatialTreeNames
        let index = staticDataStructureIndex
        return (index < names.count) ? names[index] : nil
    }

    var nextDynamicDataStructureName: String? {
        let names = SpatialTreeFactory.spatialTreeNames
        let index = dynamicDataStructureIndex
        return (index < names.count) ? names[index] : nil
    }

    var nextNumberOfObjects: Int? {
        let numbers = SpatialTreeFactory.numbersOfObjects
        let index = numberOfObjectsIndex
        return (index < numbers.count) ? numbers[index] : nil
    }

    var numberOfSimulationsToRun: Int {
        let names = SpatialTreeFactory.spatialTreeNames
        let numbers = SpatialTreeFactory.numbersOfObjects
        return names.count * names.count * numbers.count
    }

    var numberOfSimulationsCompleted: Int {
        return results.count
    }

    private func runSimulation(staticDataStructureName: String, _ dynamicDataStructureName: String, _ numberOfObjects: Int) -> Int {
        NSLog("Running simulation: \(staticDataStructureName), \(dynamicDataStructureName), \(numberOfObjects)")

        var ticks: UInt64 = 0
        let scene = Scene()
        scene.rebuildSpatialTrees(staticDataStructureName, dynamicDataStructureName, numberOfObjects: numberOfObjects)

        for _ in 0..<framesPerSimulation {
            let ticks1 = Util.getTicks()
            scene.cycle(timeStep, true)
            let ticks2 = Util.getTicks()
            ticks += (ticks2 - ticks1)
        }

        return Int(ticks / framesPerSimulation)
    }

    func runNextSimulation() {
        if nextNumberOfObjects == nil {
            numberOfObjectsIndex = 0
            dynamicDataStructureIndex += 1
            if nextDynamicDataStructureName == nil {
                dynamicDataStructureIndex = 0
                staticDataStructureIndex += 1
            }
        }

        guard nextStaticDataStructureName != nil else {
            return
        }

        let averageMillisecondsPerFrame = runSimulation(nextStaticDataStructureName!, nextDynamicDataStructureName!, nextNumberOfObjects!)
        results.append((nextStaticDataStructureName!, nextDynamicDataStructureName!, nextNumberOfObjects!, averageMillisecondsPerFrame))

        numberOfObjectsIndex += 1
    }

    func exportCSV(url: NSURL) throws {
        var csv = "\"Static/Dynamic Data Structure\""
        for i in SpatialTreeFactory.numbersOfObjects {
            csv += ",\"\(i)\""
        }

        var lastNumObjects = 0
        for results in self.results {
            if lastNumObjects == 0 || results.numberOfObjects < lastNumObjects {
                csv += "\n\"\(results.staticDataStructureName)/\(results.dynamicDataStructureName)\""
            }

            lastNumObjects = results.numberOfObjects

            csv += ",\"\(results.averageMillisecondsPerFrame)\""
        }

        try csv.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
    }
}
