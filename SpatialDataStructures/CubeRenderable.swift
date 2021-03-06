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

class CubeRenderable: Renderable {
    private var numVertices = 0
    private var vertexArrayId: GLuint = 0
    private var bufferId: GLuint = 0

    private var programPositionLocation: GLuint?

    init(program: ShaderProgram) {
        programPositionLocation = program.getUniformLocation("position")

        let p: [Float] = [
            // front
            -1.0, 1.0, 1.0,
            1.0, 1.0, 1.0,
            1.0, 1.0, 1.0,
            1.0, -1.0, 1.0,
            1.0, -1.0, 1.0,
            -1.0, -1.0, 1.0,
            -1.0, -1.0, 1.0,
            -1.0, 1.0, 1.0,

            // back
            1.0, 1.0, -1.0,
            -1.0, 1.0, -1.0,
            -1.0, 1.0, -1.0,
            -1.0, -1.0, -1.0,
            -1.0, -1.0, -1.0,
            1.0, -1.0, -1.0,
            1.0, -1.0, -1.0,
            1.0, 1.0, -1.0,

            // left
            -1.0, 1.0, 1.0,
            -1.0, 1.0, -1.0,
            -1.0, 1.0, -1.0,
            -1.0, -1.0, -1.0,
            -1.0, -1.0, -1.0,
            -1.0, -1.0, 1.0,
            -1.0, -1.0, 1.0,
            -1.0, 1.0, 1.0,

            // right
            1.0, 1.0, -1.0,
            1.0, 1.0, 1.0,
            1.0, 1.0, 1.0,
            1.0, -1.0, 1.0,
            1.0, -1.0, 1.0,
            1.0, -1.0, -1.0,
            1.0, -1.0, -1.0,
            1.0, 1.0, -1.0
        ]

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
        glDrawArrays(GLenum(GL_LINES), 0, GLint(numVertices))
    }
}
