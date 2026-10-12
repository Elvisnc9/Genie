package tech.graaf.franz.ar_flutter_plugin_plus

import android.opengl.GLES20
import android.opengl.Matrix
import com.google.ar.core.Frame
import com.google.ar.core.TrackingState
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

internal class AxisRenderer {
    private var program = 0
    private var positionAttrib = 0
    private var colorAttrib = 0
    private var mvpUniform = 0

    private val positions: FloatBuffer = ByteBuffer.allocateDirect(6 * 3 * 4)
        .order(ByteOrder.nativeOrder())
        .asFloatBuffer()
        .apply {
            put(
                floatArrayOf(
                    0f, 0f, 0f, 0.2f, 0f, 0f,  // X axis
                    0f, 0f, 0f, 0f, 0.2f, 0f,  // Y axis
                    0f, 0f, 0f, 0f, 0f, 0.2f   // Z axis
                )
            )
            position(0)
        }

    private val colors: FloatBuffer = ByteBuffer.allocateDirect(6 * 4 * 4)
        .order(ByteOrder.nativeOrder())
        .asFloatBuffer()
        .apply {
            put(
                floatArrayOf(
                    1f, 0f, 0f, 1f, 1f, 0f, 0f, 1f, // X axis (red)
                    0f, 1f, 0f, 1f, 0f, 1f, 0f, 1f, // Y axis (green)
                    0f, 0f, 1f, 1f, 0f, 0f, 1f, 1f  // Z axis (blue)
                )
            )
            position(0)
        }

    private val projection = FloatArray(16)
    private val view = FloatArray(16)
    private val model = FloatArray(16)
    private val vp = FloatArray(16)
    private val mvp = FloatArray(16)

    fun initialize() {
        program = createProgram(VERTEX_SHADER, FRAGMENT_SHADER)
        positionAttrib = GLES20.glGetAttribLocation(program, "a_Position")
        colorAttrib = GLES20.glGetAttribLocation(program, "a_Color")
        mvpUniform = GLES20.glGetUniformLocation(program, "u_MVP")
        Matrix.setIdentityM(model, 0)
    }

    fun draw(frame: Frame, modelMatrix: FloatArray) {
        val camera = frame.camera
        if (camera.trackingState != TrackingState.TRACKING) {
            return
        }

        camera.getProjectionMatrix(projection, 0, 0.1f, 100f)
        camera.getViewMatrix(view, 0)
        Matrix.multiplyMM(vp, 0, projection, 0, view, 0)
        Matrix.multiplyMM(mvp, 0, vp, 0, modelMatrix, 0)

        GLES20.glUseProgram(program)

        GLES20.glEnableVertexAttribArray(positionAttrib)
        GLES20.glVertexAttribPointer(positionAttrib, 3, GLES20.GL_FLOAT, false, 0, positions)

        GLES20.glEnableVertexAttribArray(colorAttrib)
        GLES20.glVertexAttribPointer(colorAttrib, 4, GLES20.GL_FLOAT, false, 0, colors)

        GLES20.glUniformMatrix4fv(mvpUniform, 1, false, mvp, 0)

        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
        GLES20.glLineWidth(4f)
        GLES20.glDrawArrays(GLES20.GL_LINES, 0, 6)
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)

        GLES20.glDisableVertexAttribArray(positionAttrib)
        GLES20.glDisableVertexAttribArray(colorAttrib)
    }

    private fun createProgram(vertex: String, fragment: String): Int {
        val vertexShader = loadShader(GLES20.GL_VERTEX_SHADER, vertex)
        val fragmentShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragment)
        val program = GLES20.glCreateProgram()
        GLES20.glAttachShader(program, vertexShader)
        GLES20.glAttachShader(program, fragmentShader)
        GLES20.glLinkProgram(program)
        return program
    }

    private fun loadShader(type: Int, shaderCode: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, shaderCode)
        GLES20.glCompileShader(shader)
        return shader
    }

    companion object {
        private const val VERTEX_SHADER = """
            attribute vec4 a_Position;
            attribute vec4 a_Color;
            uniform mat4 u_MVP;
            varying vec4 v_Color;
            void main() {
              gl_Position = u_MVP * a_Position;
              v_Color = a_Color;
            }
        """

        private const val FRAGMENT_SHADER = """
            precision mediump float;
            varying vec4 v_Color;
            void main() {
              gl_FragColor = v_Color;
            }
        """
    }
}
