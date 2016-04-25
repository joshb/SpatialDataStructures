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

// This file contains a BSP tree implementation. For more information on
// BSP trees, refer to the following references:
//
// - T. Akenine-Möller and E. Haines, Real-Time Rendering, 2nd ed.
//   Wellesley, MA: A K Peters, 2002, ch. 9, pp. 345-355.
//
// - M. S. Paterson and F. F. Yao, “Binary Partitions with Applications
//   to Hidden-Surface Removal and Solid Modelling,” ACM Proceedings of
//   the fifth annual symposium on Computational geometry, pp. 23-32, 1989.

import Foundation

/// Represents a single node of a BSP tree. Each instance may contain either
/// zero or two subtrees in order to construct a complete BSP hierarchy.
class BSPTree: SpatialTree {
    var box: Box
    var objects = Set<SpatialObject>()
    
    private var leafObject: SpatialObject?

    var leftSubtree: BSPTree?
    var rightSubtree: BSPTree?

    init(_ box: Box, leafObject: SpatialObject? = nil) {
        self.box = box
        self.leafObject = leafObject

        if let obj = self.leafObject {
            objects.insert(obj)
        }
    }

    var subtrees: [SpatialTree] {
        if leftSubtree != nil {
            return [leftSubtree!, rightSubtree!]
        } else {
            return []
        }
    }

    func optimize() {
        if objects.count == 0 {
            return
        } else if objects.count == 1 {
            leafObject = objects.first
            return
        } else if objects.count == 2 {
            var objs = objects
            let obj1 = objs.removeFirst()
            let obj2 = objs.removeFirst()
            split(obj1, obj2)
            return
        }

        var avg = Vector3()
        for obj in objects {
            avg = avg + obj.boundingVolume.position
        }
        avg = (avg / Float(objects.count)).clamp(min: box.min, max: box.max)

        var xsum = 0
        var ysum = 0
        var zsum = 0

        for obj in objects {
            let objPosition = obj.boundingVolume.position

            if objPosition.x > avg.x {
                xsum += 1
            } else {
                xsum -= 1
            }

            if objPosition.y > avg.y {
                ysum += 1
            } else {
                ysum -= 1
            }

            if objPosition.z > avg.z {
                zsum += 1
            } else {
                zsum -= 1
            }
        }

        xsum = abs(xsum)
        ysum = abs(ysum)
        zsum = abs(zsum)

        let min = box.min
        let max = box.max

        var leftBox: Box
        var rightBox: Box
        var leftObjects = Set<SpatialObject>()
        var rightObjects = Set<SpatialObject>()

        if xsum < ysum && xsum < zsum {
            leftBox = Box(min: min, max: Vector3(avg.x, max.y, max.z))
            rightBox = Box(min: Vector3(avg.x, min.y, min.z), max: max)

            for obj in objects {
                if obj.boundingVolume.position.x > avg.x {
                    rightObjects.insert(obj)
                } else {
                    leftObjects.insert(obj)
                }
            }
        } else if ysum < xsum && ysum < zsum {
            leftBox = Box(min: min, max: Vector3(max.x, avg.y, max.z))
            rightBox = Box(min: Vector3(min.x, avg.y, min.z), max: max)

            for obj in objects {
                if obj.boundingVolume.position.y > avg.y {
                    rightObjects.insert(obj)
                } else {
                    leftObjects.insert(obj)
                }
            }
        } else {
            leftBox = Box(min: min, max: Vector3(max.x, max.y, avg.z))
            rightBox = Box(min: Vector3(min.x, min.y, avg.z), max: max)

            for obj in objects {
                if obj.boundingVolume.position.z > avg.z {
                    rightObjects.insert(obj)
                } else {
                    leftObjects.insert(obj)
                }
            }
        }

        if leftObjects.count == 0 {
            leftObjects.insert(rightObjects.removeFirst())
        } else if rightObjects.count == 0 {
            rightObjects.insert(leftObjects.removeFirst())
        }

        leftSubtree = BSPTree(leftBox)
        leftSubtree!.objects = leftObjects
        leftSubtree!.optimize()

        rightSubtree = BSPTree(rightBox)
        rightSubtree!.objects = rightObjects
        rightSubtree!.optimize()

        for obj in objects {
            leftSubtree!.addObject(obj)
            rightSubtree!.addObject(obj)
        }
    }

    func split(obj1: SpatialObject, _ obj2: SpatialObject) {
        let min = box.min
        let max = box.max

        let mid = (obj2.boundingVolume.position - obj1.boundingVolume.position) / 2.0
        let midAbs = mid.absolute

        var leftBox: Box
        var rightBox: Box
        var leftObj: SpatialObject
        var rightObj: SpatialObject

        if midAbs.x > midAbs.y && midAbs.x > midAbs.z {
            let x = obj1.boundingVolume.position.x + mid.x
            leftBox = Box(min: min, max: Vector3(x, max.y, max.z))
            rightBox = Box(min: Vector3(x, min.y, min.z), max: max)

            if mid.x > 0.0 {
                leftObj = obj1
                rightObj = obj2
            } else {
                leftObj = obj2
                rightObj = obj1
            }
        } else if midAbs.y > midAbs.x && midAbs.y > midAbs.z {
            let y = obj1.boundingVolume.position.y + mid.y
            leftBox = Box(min: min, max: Vector3(max.x, y, max.z))
            rightBox = Box(min: Vector3(min.x, y, min.z), max: max)

            if mid.y > 0.0 {
                leftObj = obj1
                rightObj = obj2
            } else {
                leftObj = obj2
                rightObj = obj1
            }
        } else {
            let z = obj1.boundingVolume.position.z + mid.z
            leftBox = Box(min: min, max: Vector3(max.x, max.y, z))
            rightBox = Box(min: Vector3(min.x, min.y, z), max: max)

            if mid.z > 0.0 {
                leftObj = obj1
                rightObj = obj2
            } else {
                leftObj = obj2
                rightObj = obj1
            }
        }

        leafObject = nil
        leftSubtree = BSPTree(leftBox, leafObject: leftObj)
        rightSubtree = BSPTree(rightBox, leafObject: rightObj)
    }

    func merge() {
        leftSubtree = nil
        rightSubtree = nil
    }

    func addObject(obj: SpatialObject) -> Bool {
        if objects.contains(obj) {
            return true
        }

        if !objectInTreeBox(obj) {
            return false
        }

        objects.insert(obj)

        if leftSubtree == nil {
            if let leafObject = self.leafObject {
                split(leafObject, obj)
            } else {
                leafObject = obj
            }
        } else {
            leftSubtree!.addObject(obj)
            rightSubtree!.addObject(obj)
        }

        return true
    }

    func removeObject(obj: SpatialObject) -> Bool {
        if objects.remove(obj) == nil {
            return false
        }

        if leftSubtree != nil {
            // If this object is the leaf object for either
            // subtree, then we can merge this node.
            if obj == leftSubtree!.leafObject {
                leafObject = rightSubtree!.leafObject
                merge()
            } else if obj == rightSubtree!.leafObject {
                leafObject = leftSubtree!.leafObject
                merge()
            } else {
                leftSubtree!.removeObject(obj)
                rightSubtree!.removeObject(obj)
            }
        }

        return true
    }
}
