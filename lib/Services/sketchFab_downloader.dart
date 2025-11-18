// robust Sketchfab download helper + debug helpers
// - recursively searches model JSON for URLs ending with .glb/.gltf/.zip
// - exposes a public helper to collect all URL-like strings for debugging
// - downloads a direct .glb/.gltf or a ZIP, extracts it and returns the local .glb/.gltf path
//
// Usage:
// final urls = SketchfabDownloader.collectAllUrlsFromModelJson(full.raw);
// debugPrint(urls.join('\n'));
// final path = await SketchfabDownloader.downloadModelAssetFromModelJson(full.raw);

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

class SketchfabDownloader {
  /// Public debug helper: collect any string that looks like an http(s) URL
  /// from the given JSON node (model JSON or inner format entry).
  static List<String> collectAllUrlsFromModelJson(dynamic modelJson) {
    return _collectUrls(modelJson);
  }

  /// Given parsed model JSON, try to find and download a GLB/GLTF or ZIP containing one.
  static Future<String?> downloadModelAssetFromModelJson(
    Map<String, dynamic> modelJson, {
    http.Client? client,
  }) async {
    client ??= http.Client();
    try {
      final urls = _collectUrls(modelJson);

      // Prefer .glb/.gltf
      final glbUrl = urls.firstWhere(
        (u) {
          final l = u.toLowerCase();
          return l.contains('.glb') || l.contains('.gltf');
        },
        orElse: () => '',
      );
      if (glbUrl.isNotEmpty) {
        final local = await _downloadToTempFile(glbUrl, client: client);
        if (local != null) return local;
      }

      // Look for zip archives
      final zipUrl = urls.firstWhere((u) => u.toLowerCase().endsWith('.zip'), orElse: () => '');
      if (zipUrl.isNotEmpty) {
        final zipFile = await _downloadToTempFile(zipUrl, client: client);
        if (zipFile == null) return null;
        final extracted = await _extractAndFindModel(zipFile);
        return extracted;
      }

      // Fallback: inspect formats entry if present (some responses use nested objects)
      final formats = modelJson['formats'] as List<dynamic>?;
      if (formats != null) {
        for (final f in formats) {
          final candidateUrls = _collectUrls(f);
          for (final c in candidateUrls) {
            final lc = c.toLowerCase();
            if (lc.contains('.glb') || lc.contains('.gltf')) {
              final local = await _downloadToTempFile(c, client: client);
              if (local != null) return local;
            } else if (lc.endsWith('.zip')) {
              final zipFile = await _downloadToTempFile(c, client: client);
              if (zipFile == null) continue;
              final extracted = await _extractAndFindModel(zipFile);
              if (extracted != null) return extracted;
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('SketchfabDownloader error: $e');
      return null;
    } finally {
      client?.close();
    }
  }

  // ----------------------- Internal helpers -----------------------
  static List<String> _collectUrls(dynamic node) {
    final urls = <String>[];
    void walk(dynamic n) {
      if (n == null) return;
      if (n is String) {
        final s = n.trim();
        if (_looksLikeUrl(s)) urls.add(s);
      } else if (n is Map) {
        for (final v in n.values) walk(v);
      } else if (n is Iterable) {
        for (final v in n) walk(v);
      }
    }

    walk(node);

    final seen = <String>{};
    final out = <String>[];
    for (final u in urls) {
      if (!seen.contains(u)) {
        seen.add(u);
        out.add(u);
      }
    }
    return out;
  }

  static bool _looksLikeUrl(String s) {
    final lower = s.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  static Future<String?> _downloadToTempFile(String url, {http.Client? client}) async {
    client ??= http.Client();
    try {
      final res = await client.get(Uri.parse(url));
      if (res.statusCode != 200) {
        print('Download failed ${res.statusCode} for $url');
        return null;
      }
      final tmp = await getTemporaryDirectory();
      final filename = _filenameFromUrl(url);
      final outPath = p.join(tmp.path, filename);
      final outFile = File(outPath);
      await outFile.writeAsBytes(res.bodyBytes);
      return outFile.path;
    } catch (e) {
      print('Download exception for $url: $e');
      return null;
    }
  }

  static String _filenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) return segments.last;
    } catch (_) {}
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static Future<String?> _extractAndFindModel(String zipFilePath) async {
    try {
      final bytes = File(zipFilePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      final tmp = await getTemporaryDirectory();
      final extractDir = Directory(p.join(tmp.path, 'skfb_extract_${DateTime.now().millisecondsSinceEpoch}'));
      await extractDir.create(recursive: true);
      for (final file in archive) {
        if (file.isFile) {
          final outPath = p.join(extractDir.path, file.name);
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          outFile.writeAsBytesSync(file.content as List<int>);
        }
      }
      final modelFiles = extractDir.listSync(recursive: true).whereType<File>().toList();
      for (final f in modelFiles) {
        final ext = p.extension(f.path).toLowerCase();
        if (ext == '.glb' || ext == '.gltf') return f.path;
      }
      return null;
    } catch (e) {
      print('Error extracting zip $zipFilePath: $e');
      return null;
    }
  }
}