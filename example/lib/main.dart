import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

const kPluginName = 'flutter_media_metadata';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kPluginName,
        ),
      ),
      backgroundColor: Color(0xFF121212),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FilePicker.platform.pickFiles()
            ..then(
              (result) async {
                if (result == null) return;
                if (result.count == 0) return;
                print(Uri.file(result.files.first.path!));
                MetadataRetriever.fromUri(
                  Uri.file(result.files.first.path!),
                  coverDirectory: (await path.getExternalStorageDirectory())!,
                )
                  ..then(
                    (metadata) {
                      setState(() {
                        _child = ListView(
                          scrollDirection: MediaQuery.of(context).size.height >
                                  MediaQuery.of(context).size.width
                              ? Axis.vertical
                              : Axis.horizontal,
                          children: [
                            SizedBox(
                              width: 16.0,
                            ),
                            SingleChildScrollView(
                              scrollDirection:
                                  MediaQuery.of(context).size.height >
                                          MediaQuery.of(context).size.width
                                      ? Axis.horizontal
                                      : Axis.vertical,
                              child: DataTable(
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Property',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Value',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: [
                                  DataRow(
                                    cells: [
                                      DataCell(Text('trackName')),
                                      DataCell(Text('${metadata.trackName}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('trackArtistNames')),
                                      DataCell(
                                          Text('${metadata.trackArtistNames}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('albumName')),
                                      DataCell(Text('${metadata.albumName}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('albumArtistName')),
                                      DataCell(
                                          Text('${metadata.albumArtistName}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('trackNumber')),
                                      DataCell(Text('${metadata.trackNumber}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('albumLength')),
                                      DataCell(Text('${metadata.albumLength}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('year')),
                                      DataCell(Text('${metadata.year}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('genre')),
                                      DataCell(Text('${metadata.genre}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('authorName')),
                                      DataCell(Text('${metadata.authorName}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('writerName')),
                                      DataCell(Text('${metadata.writerName}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('discNumber')),
                                      DataCell(Text('${metadata.discNumber}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('mimeType')),
                                      DataCell(Text('${metadata.mimeType}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('duration')),
                                      DataCell(Text('${metadata.duration}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('bitrate')),
                                      DataCell(Text('${metadata.bitrate}')),
                                    ],
                                  ),
                                  DataRow(
                                    cells: [
                                      DataCell(Text('uri')),
                                      DataCell(Text('${metadata.uri}')),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      });
                    },
                  )
                  ..catchError((_) {
                    setState(() {
                      _child = Text('Couldn\'t extract metadata');
                    });
                  });
              },
            )
            ..catchError((_) {
              setState(() {
                _child = Text('Couldn\'t to select file');
              });
            });
        },
        child: Icon(Icons.file_present),
      ),
      body: Center(
        child: _child ?? Text('Press FAB to open a media file'),
      ),
    );
  }
}
