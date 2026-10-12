package tech.graaf.franz.ar_flutter_plugin_plus.Serialization

import com.google.ar.core.*

fun serializeHitResult(hitResult: HitResult): HashMap<String, Any> {
    val serializedHitResult = HashMap<String,Any>()

    if (hitResult.trackable is Plane && (hitResult.trackable as Plane).isPoseInPolygon(hitResult.hitPose)) {
        serializedHitResult["type"] = 1 // Type plane
    }
    else if (hitResult.trackable is Point){
        serializedHitResult["type"] = 2 // Type point
    } else {
        serializedHitResult["type"] = 0 // Type undefined
    }

    serializedHitResult["distance"] = hitResult.distance.toDouble()
    serializedHitResult["worldTransform"] = serializePose(hitResult.hitPose)

    return serializedHitResult
}

fun serializePose(pose: Pose): DoubleArray {
    val serializedPose = FloatArray(16)
    pose.toMatrix(serializedPose, 0)
    // copy into double Array
    val serializedPoseDouble = DoubleArray(serializedPose.size)
    for (i in serializedPose.indices) {
        serializedPoseDouble[i] = serializedPose[i].toDouble()
    }
    return serializedPoseDouble
}

fun serializePoseWithScale(pose: Pose, scale: FloatArray): DoubleArray {
    val serializedPose = FloatArray(16)
    pose.toMatrix(serializedPose, 0)
    // copy into double Array
    val serializedPoseDouble = DoubleArray(serializedPose.size)
    for (i in serializedPose.indices) {
        serializedPoseDouble[i] = serializedPose[i].toDouble()
        if (i == 0 || i == 4 || i == 8){
            serializedPoseDouble[i] = serializedPoseDouble[i] * scale[0]
        }
        if (i == 1 || i == 5 || i == 9){
            serializedPoseDouble[i] = serializedPoseDouble[i] * scale[1]
        }
        if (i == 2 || i == 7 || i == 10){
            serializedPoseDouble[i] = serializedPoseDouble[i] * scale[2]
        }
    }
    return serializedPoseDouble
}

fun serializeAnchor(anchorName: String, anchor: Anchor?, childNodeNames: List<String>): HashMap<String, Any?> {
    val serializedAnchor = HashMap<String, Any?>()
    serializedAnchor["type"] = 0 // index for plane anchors
    serializedAnchor["name"] = anchorName
    serializedAnchor["cloudanchorid"] = anchor?.cloudAnchorId
    serializedAnchor["transformation"] = if (anchor != null) serializePose(anchor.pose) else null
    serializedAnchor["childNodes"] = childNodeNames

    return serializedAnchor
}
