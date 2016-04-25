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

struct Vector3: CustomStringConvertible {
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0

    init(_ x: Float = 0.0, _ y: Float = 0.0, _ z: Float = 0.0) {
        self.x = x
        self.y = y
        self.z = z
    }

    func dotProduct(v: Vector3) -> Float {
        return x * v.x + y * v.y + z * v.z
    }

    var length: Float {
        return sqrtf(dotProduct(self))
    }

    var absolute: Vector3 {
        let x = (self.x >= 0.0 ? self.x : -self.x)
        let y = (self.y >= 0.0 ? self.y : -self.y)
        let z = (self.z >= 0.0 ? self.z : -self.z)
        return Vector3(x, y, z)
    }

    var normalized: Vector3 {
        let scale = 1.0 / length
        return Vector3(x * scale, y * scale, z * scale)
    }

    func crossProduct(v: Vector3) -> Vector3 {
        return Vector3(y * v.z - z * v.y,
                       z * v.x - x * v.z,
                       x * v.y - y * v.x)
    }

    func clamp(min min: Vector3, max: Vector3) -> Vector3 {
        var x = self.x
        var y = self.y
        var z = self.z

        if x < min.x {
            x = min.x
        } else if x > max.x {
            x = max.x
        }

        if y < min.y {
            y = min.y
        } else if y > max.y {
            y = max.y
        }

        if z < min.z {
            z = min.z
        } else if z > max.z {
            z = max.z
        }

        return Vector3(x, y, z)
    }

    static func random() -> Vector3 {
        let x = Util.randomFloat() * 2.0 - 1.0
        let y = Util.randomFloat() * 2.0 - 1.0
        let z = Util.randomFloat() * 2.0 - 1.0
        return Vector3(x, y, z)
    }

    var description: String {
        return "(\(x), \(y), \(z))"
    }
}

func + (v1: Vector3, v2: Vector3) -> Vector3 {
    return Vector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
}

func + (v: Vector3, f: Float) -> Vector3 {
    return Vector3(v.x + f, v.y + f, v.z + f)
}

func - (v1: Vector3, v2: Vector3) -> Vector3 {
    return Vector3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
}

func - (v: Vector3, f: Float) -> Vector3 {
    return Vector3(v.x - f, v.y - f, v.z - f)
}

func * (v1: Vector3, v2: Vector3) -> Vector3 {
    return Vector3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z)
}

func * (v: Vector3, f: Float) -> Vector3 {
    return Vector3(v.x * f, v.y * f, v.z * f)
}

func / (v: Vector3, f: Float) -> Vector3 {
    return Vector3(v.x / f, v.y / f, v.z / f)
}
