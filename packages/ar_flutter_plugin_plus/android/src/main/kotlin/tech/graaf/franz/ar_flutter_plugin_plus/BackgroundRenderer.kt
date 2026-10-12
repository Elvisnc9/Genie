package tech.graaf.franz.ar_flutter_plugin_plus

import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.opengl.Matrix
import com.google.ar.core.Frame
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

internal class BackgroundRenderer {
    var textureId: Int = -1
        private set

    private var program = 0
    private var positionAttrib = 0
    private var texCoordAttrib = 0
    private var texTransformUniform = 0
    private var samplerUniform = 0

    private val quadCoords: FloatBuffer = ByteBuffer.allocateDirect(4 * 2 * 4)
        .order(ByteOrder.nativeOrder())
        .asFloatBuffer()
        .apply {
            put(floatArrayOf(-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f))
            position(0)
        }

    private val quadTexCoords: FloatBuffer = ByteBuffer.allocateDirect(4 * 2 * 4)
        .order(ByteOrder.nativeOrder())
        .asFloatBuffer()
        .apply {
            put(floatArrayOf(0f, 1f, 1f, 1f, 0f, 0f, 1f, 0f))
            position(0)
        }

    private val texTransform = FloatArray(16)

    fun initialize() {
        textureId = createCameraTexture()
        program = createProgram(VERTEX_SHADER, FRAGMENT_SHADER)
        positionAttrib = GLES20.glGetAttribLocation(program, "a_Position")
        texCoordAttrib = GLES20.glGetAttribLocation(program, "a_TexCoord")
        texTransformUniform = GLES20.glGetUniformLocation(program, "u_TexTransform")
        samplerUniform = GLES20.glGetUniformLocation(program, "sTexture")
        Matrix.setIdentityM(texTransform, 0)
    }

    fun draw(frame: Frame) {
        quadCoords.position(0)
        quadTexCoords.position(0)
        frame.transformCoordinates2d(
            com.google.ar.core.Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES,
            quadCoords,
            com.google.ar.core.Coordinates2d.TEXTURE_NORMALIZED,
            quadTexCoords
        )
        quadCoords.position(0)
        quadTexCoords.position(0)

        GLES20.glUseProgram(program)

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)
        GLES20.glUniform1i(samplerUniform, 0)

        GLES20.glEnableVertexAttribArray(positionAttrib)
        GLES20.glVertexAttribPointer(positionAttrib, 2, GLES20.GL_FLOAT, false, 0, quadCoords)

        GLES20.glEnableVertexAttribArray(texCoordAttrib)
        GLES20.glVertexAttribPointer(texCoordAttrib, 2, GLES20.GL_FLOAT, false, 0, quadTexCoords)

        GLES20.glUniformMatrix4fv(texTransformUniform, 1, false, texTransform, 0)

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        GLES20.glDisableVertexAttribArray(positionAttrib)
        GLES20.glDisableVertexAttribArray(texCoordAttrib)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0)
    }

    private fun createCameraTexture(): Int {
        val textures = IntArray(1)
        GLES20.glGenTextures(1, textures, 0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textures[0])
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        return textures[0]
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
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            uniform mat4 u_TexTransform;
            void main() {
              gl_Position = a_Position;
              vec4 tex = u_TexTransform * vec4(a_TexCoord, 0.0, 1.0);
              v_TexCoord = tex.xy;
            }
        """

        private const val FRAGMENT_SHADER = """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            varying vec2 v_TexCoord;
            uniform samplerExternalOES sTexture;
            void main() {
              gl_FragColor = texture2D(sTexture, v_TexCoord);
            }
        """
    }
}
