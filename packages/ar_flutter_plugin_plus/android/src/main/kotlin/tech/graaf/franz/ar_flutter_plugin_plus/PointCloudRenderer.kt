package tech.graaf.franz.ar_flutter_plugin_plus

import android.opengl.GLES20
import com.google.ar.core.PointCloud
import java.nio.FloatBuffer

internal class PointCloudRenderer {
    private var program = 0
    private var positionHandle = 0
    private var viewHandle = 0
    private var projHandle = 0
    private var colorHandle = 0

    fun initialize() {
        program = createProgram(VERTEX_SHADER, FRAGMENT_SHADER)
        positionHandle = GLES20.glGetAttribLocation(program, "a_Position")
        viewHandle = GLES20.glGetUniformLocation(program, "u_View")
        projHandle = GLES20.glGetUniformLocation(program, "u_Proj")
        colorHandle = GLES20.glGetUniformLocation(program, "u_Color")
    }

    fun draw(pointCloud: PointCloud, viewMatrix: FloatArray, projectionMatrix: FloatArray) {
        if (program == 0) return
        val points = pointCloud.points
        val numPoints = points.remaining() / 4
        if (numPoints <= 0) return

        GLES20.glUseProgram(program)
        GLES20.glUniformMatrix4fv(viewHandle, 1, false, viewMatrix, 0)
        GLES20.glUniformMatrix4fv(projHandle, 1, false, projectionMatrix, 0)
        GLES20.glUniform4f(colorHandle, 1.0f, 1.0f, 1.0f, 1.0f)

        GLES20.glEnableVertexAttribArray(positionHandle)
        points.position(0)
        GLES20.glVertexAttribPointer(positionHandle, 4, GLES20.GL_FLOAT, false, 4 * 4, points)
        GLES20.glDrawArrays(GLES20.GL_POINTS, 0, numPoints)
        GLES20.glDisableVertexAttribArray(positionHandle)
    }

    private fun createProgram(vertexShaderCode: String, fragmentShaderCode: String): Int {
        val vertexShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexShaderCode)
        val fragmentShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentShaderCode)
        val program = GLES20.glCreateProgram()
        GLES20.glAttachShader(program, vertexShader)
        GLES20.glAttachShader(program, fragmentShader)
        GLES20.glLinkProgram(program)
        return program
    }

    private fun loadShader(type: Int, code: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, code)
        GLES20.glCompileShader(shader)
        return shader
    }

    companion object {
        private const val VERTEX_SHADER = """
            uniform mat4 u_View;
            uniform mat4 u_Proj;
            attribute vec4 a_Position;
            void main() {
                gl_Position = u_Proj * u_View * vec4(a_Position.xyz, 1.0);
                gl_PointSize = 6.0;
            }
        """

        private const val FRAGMENT_SHADER = """
            precision mediump float;
            uniform vec4 u_Color;
            void main() {
                gl_FragColor = u_Color;
            }
        """
    }
}
