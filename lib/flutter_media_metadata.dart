import 'dart:io';
import 'package:flutter/services.dart';

const _kChannel = MethodChannel('flutter_media_metadata');

class MetadataRetriever {
  static Future<_Metadata> fromUri(
    Uri uri, {
    Duration timeout: const Duration(seconds: 2),
    required Directory coverDirectory,
  }) async {
    try {
      final metadata = await _kChannel.invokeMethod(
        'MetadataRetriever',
        {
          'uri': uri.toString(),
          'coverDirectory': coverDirectory.path,
        },
      ).timeout(timeout);
      return _Metadata.fromJson(metadata);
    } catch (exception, stacktrace) {
      print(exception.toString());
      print(stacktrace.toString());
      return _Metadata.fromJson(
        {
          'uri': uri.toString(),
        },
      );
    }
  }
}

class _Metadata {
  final String? trackName;
  final List<String>? trackArtistNames;
  final String? albumName;
  final String? albumArtistName;
  final int? trackNumber;
  final int? albumLength;
  final int? year;
  final String? genre;
  final String? authorName;
  final String? writerName;
  final int? discNumber;
  final String? mimeType;
  final int? duration;
  final int? bitrate;
  final String? uri;

  const _Metadata({
    this.trackName,
    this.trackArtistNames,
    this.albumName,
    this.albumArtistName,
    this.trackNumber,
    this.albumLength,
    this.year,
    this.genre,
    this.authorName,
    this.writerName,
    this.discNumber,
    this.mimeType,
    this.duration,
    this.bitrate,
    this.uri,
  });

  factory _Metadata.fromJson(dynamic map) => _Metadata(
        trackName: map['trackName'],
        trackArtistNames: map['trackArtistNames']?.split('/'),
        albumName: map['albumName'],
        albumArtistName: map['albumArtistName'],
        trackNumber: _parse(map['trackNumber']),
        albumLength: _parse(map['albumLength']),
        year: _parse(map['year']),
        genre: map['genre'],
        authorName: map['authorName'],
        writerName: map['writerName'],
        discNumber: _parse(map['discNumber']),
        mimeType: map['mimeType'],
        duration: _parse(map['duration']),
        bitrate: _parse(map['bitrate']),
        uri: map['uri'],
      );

  Map<String, dynamic> toJson() => {
        'trackName': trackName,
        'trackArtistNames': trackArtistNames,
        'albumName': albumName,
        'albumArtistName': albumArtistName,
        'trackNumber': trackNumber,
        'albumLength': albumLength,
        'year': year,
        'genre': genre,
        'authorName': authorName,
        'writerName': writerName,
        'discNumber': discNumber,
        'mimeType': mimeType,
        'duration': duration,
        'bitrate': bitrate,
        'uri': uri,
      };
}

int? _parse(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  } else if (value is String) {
    try {
      try {
        return int.parse(value);
      } catch (_) {
        return int.parse(value.split('/').first);
      }
    } catch (_) {}
  }
  return null;
}
