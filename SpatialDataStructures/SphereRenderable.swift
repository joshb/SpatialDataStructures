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
import GLKit

class SphereRenderable: Renderable {
    private var numVertices = 0
    private var vertexArrayId: GLuint = 0
    private var bufferId: GLuint = 0

    private var programPositionLocation: GLuint?

    init(program: ShaderProgram, numberOfDivisions divisions: Int) {
        programPositionLocation = program.getUniformLocation("position")

        let divisionsf = Float(divisions)

        // Generate vertex data.
        var p: [Float] = []
        for i in 0...divisions/2-1 {
            for j in 0...divisions {
                let ri1 = ((M_PI_F * 2.0) / (divisionsf / 2.0)) * Float(i)
                let ri2 = ((M_PI_F * 2.0) / (divisionsf / 2.0)) * Float(i+1)
                let rj = ((M_PI_F * 2.0) / divisionsf) * Float(j)

                let ci1 = cosf(ri1)
                let si1 = sinf(ri1)
                let ci2 = cosf(ri2)
                let si2 = sinf(ri2)

                let cj = cosf(rj)
                let sj = sinf(rj)

                p.append(cj * si1)
                p.append(ci1)
                p.append(sj * si1)

                p.append(cj * si2)
                p.append(ci2)
                p.append(sj * si2)
            }
        }

        numVertices = p.count / 3

        // Get the program's vertex data locations.
        let vertexPositionLocation = program.getAttributeLocation("vertexPosition")!

        // Create vertex array.
        glGenVertexArrays(1, &vertexArrayId)
        glBindVertexArray(vertexArrayId)

        // Create buffer.
        glGenBuffers(1, &bufferId)

        // Create position buffer.
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), bufferId)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(Float) * p.count, p, GLenum(GL_STATIC_DRAW))

        // Create position attribute array.
        glEnableVertexAttribArray(vertexPositionLocation)
        glVertexAttribPointer(vertexPositionLocation, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
    }

    deinit {
        glDeleteBuffers(1, &bufferId)
        glDeleteVertexArrays(1, &vertexArrayId)
    }

    func render(position: Vector3) {
        if let location = programPositionLocation {
            glUniform3f(GLint(location), position.x, position.y, position.z)
        }

        glBindVertexArray(vertexArrayId)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLint(numVertices))
    }
}
