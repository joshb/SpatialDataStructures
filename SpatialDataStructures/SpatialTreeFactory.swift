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

/// Maintains a list of spatial data structure names and
/// functions for creating instances of those data structure.
class SpatialTreeFactory {
    private typealias SpatialTreeBuilder = (name: String, builder: () -> SpatialTree)

    static let sceneMax = Vector3(1.0, 1.0, 1.0) * 80.0
    static let sceneMin = sceneMax * -1.0

    /// Name of the default spatial data structure.
    static var defaultSpatialTreeName: String {
        return spatialTreeBuilders[0].name
    }

    private static var spatialTreeBuilders: [SpatialTreeBuilder] = [
        //("No-op", { NoOpTree(Box(min: sceneMin, max: sceneMax)) }),
        ("BSP", { BSPTree(Box(min: sceneMin, max: sceneMax)) }),
        ("Octree", { Octree(Box(min: sceneMin, max: sceneMax), 25.0) }),
    ]

    /// Array of strings containing the names of registered data structures.
    static var spatialTreeNames: [String] {
        return spatialTreeBuilders.flatMap({ $0.0 })
    }

    /// Array of numbers of objects that can be in the scene.
    static var numbersOfObjects: [Int] {
        return [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]
    }

    /// Build an instance of a spatial data structure with the given name.
    ///
    /// - parameter name: String containing the name of the data structure.
    /// - returns: SpatialTree or nil if no registered data structure has the given name.
    static func buildSpatialTree(name: String) -> SpatialTree? {
        let builder = spatialTreeBuilders.filter({ $0.name == name })
        guard builder.count != 0 else {
            return nil
        }

        return builder[0].builder()
    }
}
