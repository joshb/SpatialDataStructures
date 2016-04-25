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

/// Represents a node of a spatial data tree structure. Each node may contain
/// subtrees in order to construct a complete spatial data hierarchy.
protocol SpatialTree {
    /// The bounding box for the tree node.
    var box: Box { get }

    /// Array of immediate subtrees of the tree node.
    var subtrees: [SpatialTree] { get }
    
    /// Set of all SpatialObjects in the data structure.
    var objects: Set<SpatialObject> { get }

    /// Optimize the data structure for quickly accessing data.
    func optimize()

    /// Add the given object to the data structure.
    ///
    /// - parameter obj: SpatialObject to add to the data structure.
    /// - returns: True if the object was added, or false if it wasn't,
    ///   which may happen if the object is outside of the tree's boundaries.
    func addObject(obj: SpatialObject) -> Bool

    /// Remove the given object from the data structure.
    ///
    /// - parameter obj: SpatialObject to remove from the data structure.
    /// - returns: True if the object was removed, or false if the object
    ///   is not in the tree.
    func removeObject(obj: SpatialObject) -> Bool
}

extension SpatialTree {
    func objectInTreeBox(obj: SpatialObject) -> Bool {
        return obj.boundingVolume.intersects(box) != nil
    }

    /// Update the given object in the data structure. This should be done
    /// when an object's position and/or bounding volume has changed.
    ///
    /// - parameter obj: SpatialObject to update in the data structure.
    /// - returns: True if the object was updated, or false if the object
    ///   is not in the tree.
    func updateObject(obj: SpatialObject) -> Bool {
        if !removeObject(obj) {
            return false
        }

        return addObject(obj)
    }

    /// Render all objects in the data structure.
    func renderObjects() {
        for obj in objects {
            obj.render()
        }
    }

    /// Cycle all objects in the data structure.
    ///
    /// - parameter secondsElapsed: The number of seconds that have elapsed since the last cycle.
    /// - parameter staticSpatialTree: SpatialTree containing static objects.
    func cycleObjects(secondsElapsed: Float, collisionDetection: Bool, staticSpatialTree: SpatialTree? = nil) {
        let objects = self.objects
        for obj in objects {
            var intersectingObjects: Set<SpatialObject>

            if collisionDetection {
                intersectingObjects = self.findIntersectingObjects(obj)
                if let tree = staticSpatialTree {
                    intersectingObjects = intersectingObjects.union(tree.findIntersectingObjects(obj))
                }
            } else {
                intersectingObjects = Set<SpatialObject>()
            }

            obj.cycle(secondsElapsed, intersectingObjects: intersectingObjects)
            self.updateObject(obj)
        }
    }

    /// Render each node in the tree.
    ///
    /// - parameter renderable: Cube renderable to use for rendering each node of the tree.
    /// - parameter program: ShaderProgram for the cube renderable.
    func renderTree(renderable renderable: Renderable, program: ShaderProgram) {
        let subtrees = self.subtrees
        if subtrees.count == 0 {
            program.setUniform("scale", vector: box.size / 2)
            renderable.render(box.position)
        } else {
            for subtree in subtrees {
                subtree.renderTree(renderable: renderable, program: program)
            }
        }
    }

    /// Find all objects in the data structure that intersect the given object.
    ///
    /// - parameter obj: SpatialObject to find intersecting objects for.
    /// - returns: Set of SpatialObjects that intersect the given object.
    func findIntersectingObjects(obj: SpatialObject) -> Set<SpatialObject> {
        var intersectingObjects = Set<SpatialObject>()

        if !objectInTreeBox(obj) {
            return intersectingObjects
        }

        if subtrees.count == 0 {
            for otherObj in objects {
                if otherObj != obj && otherObj.boundingVolume.intersects(obj.boundingVolume) != nil {
                    intersectingObjects.insert(otherObj)
                }
            }
        } else {
            for subtree in subtrees {
                intersectingObjects = intersectingObjects.union(subtree.findIntersectingObjects(obj))
            }
        }

        return intersectingObjects
    }
}
