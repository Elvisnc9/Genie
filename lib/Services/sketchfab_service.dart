import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sketchfab service for searching models and fetching model details.
/// IMPORTANT: create an API token in Sketchfab and pass it into SketchfabService(token).
class SketchfabService {
  final String token;
  SketchfabService(this.token);

  Future<List<SketchfabModel>> searchModels(String query, {int pageSize = 20}) async {
    final uri = Uri.https('api.sketchfab.com', '/v3/search', {
      'type': 'models',
      'q': query,
      'downloadable': 'true', // optional: only downloadable results to simplify demo
      'page': '1',
      'page_size': pageSize.toString(),
    });

    final res = await http.get(uri, headers: {
      'Authorization': 'Token $token',
      'Accept': 'application/json',
    });

    if (res.statusCode != 200) {
      throw Exception('Sketchfab search failed: ${res.statusCode}: ${res.body}');
    }
    final Map<String, dynamic> jsonBody = json.decode(res.body);
    final List<dynamic> results = jsonBody['results'] ?? [];
    return results.map((e) => SketchfabModel.fromJson(e)).toList();
  }

  Future<SketchfabModel?> getModel(String uid) async {
    final uri = Uri.https('api.sketchfab.com', '/v3/models/$uid');
    final res = await http.get(uri, headers: {
      'Authorization': 'Token $token',
      'Accept': 'application/json',
    });
    if (res.statusCode != 200) return null;
    final Map<String, dynamic> jsonBody = json.decode(res.body);
    return SketchfabModel.fromJson(jsonBody);
  }
}

class SketchfabModel {
  final String uid;
  final String name;
  final bool isDownloadable;
  final String viewerUrl;
  final List<String> thumbnails;
  final List<String> downloadableFormats;
  final Map<String, dynamic> raw;

  SketchfabModel({
    required this.uid,
    required this.name,
    required this.isDownloadable,
    required this.viewerUrl,
    required this.thumbnails,
    required this.downloadableFormats,
    required this.raw,
  });

  factory SketchfabModel.fromJson(Map<String, dynamic> json) {
    final thumbnails = <String>[];
    try {
      final thumbs = json['thumbnails']?['images'] as List<dynamic>?;
      if (thumbs != null) {
        for (final t in thumbs) {
          if (t['url'] != null) thumbnails.add(t['url'] as String);
        }
      }
    } catch (_) {}
    final formats = <String>[];
    try {
      final f = json['formats'] as List<dynamic>?;
      if (f != null) {
        for (final fmt in f) {
          final formatName = fmt['format']?['name'] ?? fmt['formatType'];
          if (formatName != null) formats.add(formatName.toString());
        }
      }
    } catch (_) {}
    return SketchfabModel(
      uid: json['uid'] ?? json['uri'] ?? '',
      name: json['name'] ?? '',
      isDownloadable: json['isDownloadable'] == true,
      viewerUrl: json['viewerUrl'] ?? '',
      thumbnails: thumbnails,
      downloadableFormats: formats,
      raw: json,
    );
  }
}