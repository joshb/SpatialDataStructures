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

struct Sphere: BoundingVolume {
    var position: Vector3
    var radius: Float

    init(position: Vector3 = Vector3(), radius: Float = 1.0) {
        self.position = position
        self.radius = radius
    }

    func intersects(sphere: Sphere) -> BoundingVolumeCollision? {
        let diff = position - sphere.position
        let distSquared = diff.dotProduct(diff)
        let radiusSum = sphere.radius + radius

        if distSquared > (radiusSum * radiusSum) {
            return nil
        }

        let dist = sqrtf(distSquared)
        return (diff / dist, radiusSum - dist)
    }

    func intersects(box: Box) -> BoundingVolumeCollision? {
        // Clamp the sphere position to the box boundaries
        // to get the point on the box closest to the sphere.
        let v = position.clamp(min: box.min, max: box.max)

        let diff = position - v
        let distSquared = diff.dotProduct(diff)

        if distSquared > (radius * radius) {
            return nil
        }

        let dist = sqrtf(distSquared)
        return (diff / dist, dist)
    }

    func intersects(boundingVolume: BoundingVolume) -> BoundingVolumeCollision? {
        if let sphere = boundingVolume as? Sphere {
            return intersects(sphere)
        } else if let box = boundingVolume as? Box {
            return intersects(box)
        }

        return nil
    }

    var description: String {
        return "Sphere { position: \(position), radius: \(radius) }"
    }
}
