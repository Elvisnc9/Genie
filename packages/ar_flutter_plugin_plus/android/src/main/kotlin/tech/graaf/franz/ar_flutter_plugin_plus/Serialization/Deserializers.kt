package tech.graaf.franz.ar_flutter_plugin_plus.Serialization

import kotlin.math.sqrt

data class TransformComponents(
  val scale: FloatArray,
  val position: FloatArray,
  val rotation: FloatArray
)

fun deserializeMatrix4(transform: ArrayList<Double>): TransformComponents {
  // Calculate scale from transformation matrix
  val scaleX = sqrt(
    transform[0] * transform[0] +
      transform[1] * transform[1] +
      transform[2] * transform[2]
  ).toFloat()
  val scaleY = sqrt(
    transform[4] * transform[4] +
      transform[5] * transform[5] +
      transform[6] * transform[6]
  ).toFloat()
  val scaleZ = sqrt(
    transform[8] * transform[8] +
      transform[9] * transform[9] +
      transform[10] * transform[10]
  ).toFloat()

  val scale = floatArrayOf(scaleX, scaleY, scaleZ)
  val position = floatArrayOf(transform[12].toFloat(), transform[13].toFloat(), transform[14].toFloat())
  var qx = 0.0
  var qy = 0.0
  var qz = 0.0
  var qw = 0.0

  // Get the rotation matrix from the transformation matrix by normalizing with the scales
  val rowWiseMatrix =
      floatArrayOf(
          transform[0].toFloat() / scaleX,
          transform[4].toFloat() / scaleY,
          transform[8].toFloat() / scaleZ,
          transform[1].toFloat() / scaleX,
          transform[5].toFloat() / scaleY,
          transform[9].toFloat() / scaleZ,
          transform[2].toFloat() / scaleX,
          transform[6].toFloat() / scaleY,
          transform[10].toFloat() / scaleZ)

  // Calculate the quaternion from the rotation matrix
  val trace = rowWiseMatrix[0] + rowWiseMatrix[4] + rowWiseMatrix[8]

  if (trace > 0) {
    val scalefactor = sqrt(trace + 1.0) * 2
    qw = 0.25 * scalefactor
    qx = (rowWiseMatrix[7] - rowWiseMatrix[5]) / scalefactor
    qy = (rowWiseMatrix[2] - rowWiseMatrix[6]) / scalefactor
    qz = (rowWiseMatrix[3] - rowWiseMatrix[1]) / scalefactor
  } else if ((rowWiseMatrix[0] > rowWiseMatrix[4]) && (rowWiseMatrix[0] > rowWiseMatrix[8])) {
    val scalefactor = sqrt(1.0 + rowWiseMatrix[0] - rowWiseMatrix[4] - rowWiseMatrix[8]) * 2
    qw = (rowWiseMatrix[7] - rowWiseMatrix[5]) / scalefactor
    qx = 0.25 * scalefactor
    qy = (rowWiseMatrix[1] + rowWiseMatrix[3]) / scalefactor
    qz = (rowWiseMatrix[2] + rowWiseMatrix[6]) / scalefactor
  } else if (rowWiseMatrix[4] > rowWiseMatrix[8]) {
    val scalefactor = sqrt(1.0 + rowWiseMatrix[4] - rowWiseMatrix[0] - rowWiseMatrix[8]) * 2
    qw = (rowWiseMatrix[2] - rowWiseMatrix[6]) / scalefactor
    qx = (rowWiseMatrix[1] + rowWiseMatrix[3]) / scalefactor
    qy = 0.25 * scalefactor
    qz = (rowWiseMatrix[5] + rowWiseMatrix[7]) / scalefactor
  } else {
    val scalefactor = sqrt(1.0 + rowWiseMatrix[8] - rowWiseMatrix[0] - rowWiseMatrix[4]) * 2
    qw = (rowWiseMatrix[3] - rowWiseMatrix[1]) / scalefactor
    qx = (rowWiseMatrix[2] + rowWiseMatrix[6]) / scalefactor
    qy = (rowWiseMatrix[5] + rowWiseMatrix[7]) / scalefactor
    qz = 0.25 * scalefactor
  }

  // Apply 180-degree corrections around Y and Z: (qx,qy,qz,qw) * (0,1,0,0) * (0,0,1,0)
  // First multiply by Y-180 (0,1,0,0)
  var rx = qx * 0.0 + qw * 1.0 + qy * 0.0 - qz * 0.0
  var ry = qy * 0.0 + qw * 0.0 + qz * 1.0 - qx * 0.0
  var rz = qz * 0.0 + qw * 0.0 + qx * 0.0 - qy * 1.0
  var rw = qw * 0.0 - qx * 1.0 - qy * 0.0 - qz * 0.0

  // Then multiply by Z-180 (0,0,1,0)
  val fx = rx * 0.0 + rw * 0.0 + ry * 1.0 - rz * 0.0
  val fy = ry * 0.0 + rw * 0.0 + rz * 0.0 - rx * 1.0
  val fz = rz * 0.0 + rw * 1.0 + rx * 0.0 - ry * 0.0
  val fw = rw * 0.0 - rx * 0.0 - ry * 1.0 - rz * 0.0

  val rotationArray = floatArrayOf(fx.toFloat(), fy.toFloat(), fz.toFloat(), fw.toFloat())
  return TransformComponents(scale, position, rotationArray)
}
