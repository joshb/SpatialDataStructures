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

struct Box: BoundingVolume {
    var min: Vector3
    var max: Vector3

    init(min: Vector3, max: Vector3) {
        var actualMin = min
        var actualMax = max

        if (actualMin.x > actualMax.x) {
            let tmp = actualMax.x
            actualMax.x = actualMin.x
            actualMin.x = tmp
        }

        if (actualMin.y > actualMax.y) {
            let tmp = actualMax.y
            actualMax.y = actualMin.y
            actualMin.y = tmp
        }

        if (actualMin.z > actualMax.z) {
            let tmp = actualMax.z
            actualMax.z = actualMin.z
            actualMin.z = tmp
        }

        self.min = actualMin
        self.max = actualMax
    }

    var size: Vector3 {
        return max - min
    }

    var mid: Vector3 {
        return min + (size / 2.0)
    }

    var position: Vector3 {
        get {
            return mid
        }

        set {
            let offset = newValue - mid
            min = min + offset
            max = max + offset
        }
    }

    func containsPoint(point: Vector3) -> Bool {
        return point.x >= min.x && point.x < max.x &&
               point.y >= min.y && point.y < max.y &&
               point.z >= min.z && point.z < max.z
    }

    func intersects(box: Box) -> BoundingVolumeCollision? {
        if max.x >= box.min.x && min.x < box.max.x &&
           max.y >= box.min.y && min.y < box.max.y &&
           max.z >= box.min.z && min.z < box.max.z {
            return (Vector3(), 1.0)
        }

        return nil
    }

    func intersects(boundingVolume: BoundingVolume) -> BoundingVolumeCollision? {
        if let box = boundingVolume as? Box {
            return intersects(box)
        } else if let sphere = boundingVolume as? Sphere {
            return sphere.intersects(self)
        }

        return nil
    }

    var description: String {
        return "Box { min: \(min), max: \(max) }"
    }
}
