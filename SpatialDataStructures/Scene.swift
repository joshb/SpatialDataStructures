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

let NUM_LIGHTS = 3

class Scene {
    private var cameraRotation: Float = 0.0
    private var cameraPosition = Vector3()

    private var cubeProgram: ShaderProgram
    private var sphereProgram: ShaderProgram

    private var cubeRenderable: Renderable
    private var sphereRenderable: Renderable

    private var staticSpatialTree: SpatialTree?
    private var dynamicSpatialTree: SpatialTree?

    init() {
        // Create the cube program.
        cubeProgram = ShaderProgram()
        cubeProgram.attachShader("cube_shader.vs", withType: GL_VERTEX_SHADER)
        cubeProgram.attachShader("cube_shader.fs", withType: GL_FRAGMENT_SHADER)
        cubeProgram.link()

        // Create the sphere program.
        sphereProgram = ShaderProgram()
        sphereProgram.attachShader("shader.vs", withType: GL_VERTEX_SHADER)
        sphereProgram.attachShader("shader.fs", withType: GL_FRAGMENT_SHADER)
        sphereProgram.link()

        cubeRenderable = CubeRenderable(program: cubeProgram)
        sphereRenderable = SphereRenderable(program: sphereProgram, numberOfDivisions: 36)
    }

    func rebuildSpatialTrees(staticSpatialTreeName: String, _ dynamicSpatialTreeName: String, numberOfObjects: Int) {
        Util.seedRandom(42)
        
        staticSpatialTree = SpatialTreeFactory.buildSpatialTree(staticSpatialTreeName)
        dynamicSpatialTree = SpatialTreeFactory.buildSpatialTree(dynamicSpatialTreeName)

        // Add objects.
        for _ in 0..<numberOfObjects/2 {
            staticSpatialTree?.addObject(SpatialObject(boundingVolume: Sphere(position: Vector3.random() * 20.0), renderable: sphereRenderable))
            dynamicSpatialTree?.addObject(SpatialObject(boundingVolume: Sphere(position: Vector3.random() * 20.0), renderable: sphereRenderable))
        }

        staticSpatialTree?.optimize()
        //dynamicSpatialTree?.optimize()

        //buildTestTrees()
    }

    func buildTestTrees() {
        staticSpatialTree = BSPTree(Box(min: Vector3(-5.0, -5.0, -5.0), max: Vector3(5.0, 5.0, 5.0)))
        dynamicSpatialTree = SpatialTreeFactory.buildSpatialTree("BSP Tree")

        staticSpatialTree?.addObject(SpatialObject(boundingVolume: Sphere(position: Vector3(0.0, -1.0, 0.0)), renderable: sphereRenderable))
        staticSpatialTree?.addObject(SpatialObject(boundingVolume: Sphere(position: Vector3(-2.5, 0.0, 0.0)), renderable: sphereRenderable))
        staticSpatialTree?.addObject(SpatialObject(boundingVolume: Sphere(position: Vector3(-2.5, 2.5, 0.0)), renderable: sphereRenderable))
        staticSpatialTree?.addObject(SpatialObject(boundingVolume: Sphere(position: Vector3(-2.5, -2.5, 0.0)), renderable: sphereRenderable))

        staticSpatialTree?.optimize()
    }

    func render(projectionMatrix: Matrix4, renderTrees: Bool) {
        let translationMatrix = Matrix4.translationMatrix(x: -cameraPosition.x, y: -cameraPosition.y, z: -cameraPosition.z)
        let rotationMatrix = Matrix4.rotationMatrix(angle: cameraRotation, x: 0.0, y: -1.0, z: 0.0)
        let modelviewMatrix = translationMatrix * rotationMatrix

        if renderTrees {
            // Use the cube program.
            cubeProgram.use()
            cubeProgram.setUniform("projectionMatrix", matrix: projectionMatrix)
            cubeProgram.setUniform("modelviewMatrix", matrix: modelviewMatrix)

            // Render the trees.
            cubeProgram.setUniform("color", vector: Vector3(1.0, 0.0, 0.0))
            staticSpatialTree?.renderTree(renderable: cubeRenderable, program: cubeProgram)
            cubeProgram.setUniform("color", vector: Vector3(0.0, 1.0, 0.0))
            dynamicSpatialTree?.renderTree(renderable: cubeRenderable, program: cubeProgram)
        }

        // Use the sphere program.
        sphereProgram.use()
        sphereProgram.setUniform("projectionMatrix", matrix: projectionMatrix)
        sphereProgram.setUniform("modelviewMatrix", matrix: modelviewMatrix)

        // Render all objects.
        staticSpatialTree?.renderObjects()
        dynamicSpatialTree?.renderObjects()

        // Disable the program.
        glUseProgram(0)
    }

    func cycle(secondsElapsed: Float, _ collisionDetection: Bool) {
        // Update the camera position.
        cameraRotation -= (M_PI_F / 32.0) * secondsElapsed
        cameraPosition = Vector3(sinf(cameraRotation), 0.0, cosf(cameraRotation)) * 60.0

        // Cycle dynamic objects.
        dynamicSpatialTree?.cycleObjects(secondsElapsed, collisionDetection: collisionDetection, staticSpatialTree: staticSpatialTree)
    }
}
