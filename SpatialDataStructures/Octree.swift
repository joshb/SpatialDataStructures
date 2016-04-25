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

// This file contains an octree implementation. For more information on
// octrees, refer to the following references:
//
// - T. Akenine-Möller and E. Haines, Real-Time Rendering, 2nd ed.
//   Wellesley, MA: A K Peters, 2002, ch. 9, pp. 345-355.
//
// - Z. Tang, “Octree Representation and Its Applications in CAD,”
//   Journal of Computer Science & Technology, vol. 7, no. 1, pp. 29-38, 1992.

import Foundation
import GLKit

/// Represents a single node of an octree. Each instance may contain either
/// zero or eight subtrees in order to construct a complete octree hierarchy.
class Octree: SpatialTree {
    var box: Box
    var subtrees: [SpatialTree] = []
    var objects = Set<SpatialObject>()

    var minSize: Float

    init(_ box: Box, _ minSize: Float = 10.0) {
        self.box = box
        self.minSize = minSize
    }

    /// Array of sub-boxes of this octree node.
    var subBoxes: [Box] {
        let min = box.min
        let max = box.max
        let mid = box.mid

        return [
            Box(min: Vector3(min.x, min.y, min.z), max: Vector3(mid.x, mid.y, mid.z)),
            Box(min: Vector3(mid.x, min.y, min.z), max: Vector3(max.x, mid.y, mid.z)),
            Box(min: Vector3(min.x, mid.y, min.z), max: Vector3(mid.x, max.y, mid.z)),
            Box(min: Vector3(mid.x, mid.y, min.z), max: Vector3(max.x, max.y, mid.z)),
            Box(min: Vector3(min.x, min.y, mid.z), max: Vector3(mid.x, mid.y, max.z)),
            Box(min: Vector3(mid.x, min.y, mid.z), max: Vector3(max.x, mid.y, max.z)),
            Box(min: Vector3(min.x, mid.y, mid.z), max: Vector3(mid.x, max.y, max.z)),
            Box(min: Vector3(mid.x, mid.y, mid.z), max: Vector3(max.x, max.y, max.z))
        ]
    }

    func optimize() {}

    /// Split the octree node into eight subtrees.
    private func split() {
        // Only split if we haven't reached the minimum size.
        let size = box.size
        if size.x < minSize && size.y < minSize && size.z < minSize {
            return
        }

        subtrees = subBoxes.flatMap({ Octree($0, minSize) })

        let objects = self.objects
        self.objects = Set<SpatialObject>()
        for obj in objects {
            addObject(obj)
        }
    }

    /// Merge the octree node so that it has no subtrees.
    private func merge() {
        subtrees = []
    }

    func addObject(obj: SpatialObject) -> Bool {
        if objects.contains(obj) {
            return true
        }
        
        if !objectInTreeBox(obj) {
            return false
        }

        objects.insert(obj)

        if subtrees.count == 0 {
            // If there are now multiple objects in the node, split it.
            if objects.count > 1 {
                split()
            }
        } else {
            for subtree in subtrees {
                subtree.addObject(obj)
            }
        }

        return true
    }

    func removeObject(obj: SpatialObject) -> Bool {
        if objects.remove(obj) == nil {
            return false
        }

        if subtrees.count != 0 {
            // If there are now less than two objects in the node, merge it.
            if objects.count < 2 {
                merge()
            } else {
                for subtree in subtrees {
                    subtree.removeObject(obj)
                }
            }
        }

        return true
    }
}
