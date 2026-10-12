package tech.graaf.franz.ar_flutter_plugin_plus

import android.util.Log
import com.google.ar.core.Anchor
import com.google.ar.core.Session

// Genie: cloud anchors are disabled in this vendored copy.
//
// The published 1.1.3 handler called Session.hostCloudAnchor /
// hostCloudAnchorWithTtl / resolveCloudAnchor, which ARCore removed (1.40+),
// so the plugin no longer compiled against ARCore 1.52. Genie never shares
// anchors, so this keeps the class's shape (AndroidARView still references it)
// and only logs if a cloud call is ever made. To bring cloud anchors back, port
// these to Session.hostCloudAnchorAsync / resolveCloudAnchorAsync.
internal class CloudAnchorHandler(@Suppress("UNUSED_PARAMETER") arSession: Session) {

    interface CloudAnchorListener {
        fun onCloudTaskComplete(anchorName: String?, anchor: Anchor?)
    }

    private val tag: String = CloudAnchorHandler::class.java.simpleName

    fun hostCloudAnchor(anchorName: String, anchor: Anchor?, listener: CloudAnchorListener?) = unsupported("host")

    fun hostCloudAnchorWithTtl(anchorName: String, anchor: Anchor?, listener: CloudAnchorListener?, ttl: Int) =
        unsupported("host")

    fun resolveCloudAnchor(anchorId: String?, listener: CloudAnchorListener?) = unsupported("resolve")

    fun onUpdate(updatedAnchors: Collection<Anchor>) {}

    fun clearListeners() {}

    private fun unsupported(what: String) {
        Log.w(tag, "Cloud anchors are disabled in Genie's build; ignoring $what request.")
    }
}
