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

/// Represents an object that can be stored in a spatial data structure.
class SpatialObject: Hashable {
    private let gravity: Float = 9.8

    private static var numSpatialObjects: Int = 0
    private var _hashValue: Int

    /// The bounding volume for the object.
    var boundingVolume: BoundingVolume

    /// Renderable for rendering the object.
    var renderable: Renderable?

    /// The velocity of the object.
    var velocity = Vector3.random() * 2.0

    init(boundingVolume: BoundingVolume, renderable: Renderable?) {
        _hashValue = SpatialObject.numSpatialObjects
        SpatialObject.numSpatialObjects += 1

        self.boundingVolume = boundingVolume
        self.renderable = renderable
    }

    var hashValue: Int {
        return _hashValue
    }

    /// Render the object.
    func render() {
        renderable?.render(boundingVolume.position)
    }

    /// Cycle the object, performing movement and collision response.
    ///
    /// - parameter secondsElapsed: The number of seconds that have elapsed since the last cycle.
    /// - parameter intersectingObjects: Set of objects intersecting this object.
    func cycle(secondsElapsed: Float, intersectingObjects: Set<SpatialObject>? = nil) {
        boundingVolume.position = boundingVolume.position + velocity * secondsElapsed
        //velocity.y = velocity.y - gravity * secondsElapsed

        for intersectingObject in intersectingObjects ?? Set<SpatialObject>() {
            if let collision = self.boundingVolume.intersects(intersectingObject.boundingVolume) {
                boundingVolume.position = boundingVolume.position + collision.direction * collision.distance

                let normal = collision.direction.normalized
                velocity = velocity + (normal * (velocity * -1.0).dotProduct(normal) * 1.5)
            }
        }
    }
}

func == (l: SpatialObject, r: SpatialObject) -> Bool {
    return l.hashValue == r.hashValue
}
