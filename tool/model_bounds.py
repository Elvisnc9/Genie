"""Prints a .glb's world-space bounding box (metres), so the catalog can
scale each model to the piece's real dimensions.  python tool/model_bounds.py assets/models/x.glb"""
import json
import struct
import sys

import numpy as np


def load(path):
    data = open(path, "rb").read()
    chunk_len, _ = struct.unpack("<II", data[12:20])  # first chunk is JSON
    return json.loads(data[20:20 + chunk_len])


def node_matrix(n):
    if "matrix" in n:
        return np.array(n["matrix"], float).reshape(4, 4).T
    t = np.array(n.get("translation", [0, 0, 0]), float)
    x, y, z, w = n.get("rotation", [0, 0, 0, 1])
    s = np.array(n.get("scale", [1, 1, 1]), float)
    r = np.array([
        [1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
        [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
        [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)],
    ])
    m = np.eye(4)
    m[:3, :3] = r * s
    m[:3, 3] = t
    return m


def bounds(gltf):
    lo, hi = np.full(3, np.inf), np.full(3, -np.inf)

    def visit(i, parent):
        nonlocal lo, hi
        n = gltf["nodes"][i]
        m = parent @ node_matrix(n)
        if "mesh" in n:
            for prim in gltf["meshes"][n["mesh"]]["primitives"]:
                acc = gltf["accessors"][prim["attributes"]["POSITION"]]
                a, b = np.array(acc["min"]), np.array(acc["max"])
                for corner in np.array(np.meshgrid(*zip(a, b))).T.reshape(-1, 3):
                    p = m @ np.append(corner, 1)
                    lo, hi = np.minimum(lo, p[:3]), np.maximum(hi, p[:3])
        for c in n.get("children", []):
            visit(c, m)

    scene = gltf["scenes"][gltf.get("scene", 0)]
    for i in scene["nodes"]:
        visit(i, np.eye(4))
    return lo, hi


if __name__ == "__main__":
    for path in sys.argv[1:]:
        lo, hi = bounds(load(path))
        size = hi - lo
        print(f"{path}: width(x) {size[0]:.3f} m, height(y) {size[1]:.3f} m, depth(z) {size[2]:.3f} m")
