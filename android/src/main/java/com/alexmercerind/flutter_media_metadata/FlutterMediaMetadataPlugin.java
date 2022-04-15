package com.alexmercerind.flutter_media_metadata;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.lang.Runnable;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java9.util.concurrent.CompletableFuture;

import android.media.MediaMetadataRetriever;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlutterMediaMetadataPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel =
                new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_media_metadata");
        channel.setMethodCallHandler(this);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result) {

        if (call.method.equals("MetadataRetriever")) {
            final String[] uri = {call.argument("uri")};
            final String[] coverDirectory = {call.argument("coverDirectory")};
            CompletableFuture.runAsync(new Runnable() {
                @Override
                public void run() {
                    final MetadataRetriever retriever = new MetadataRetriever();
                    retriever.setUri(uri[0]);
                    final HashMap<String, Object> metadata = retriever.getMetadata();
                    new Handler(Looper.getMainLooper())
                            .post(new Runnable() {
                                @Override
                                public void run() {
                                    result.success(metadata);
                                }
                            });
                    // https://github.com/harmonoid/libmpv.dart/blob/master/lib/src/tagger.dart
                    String trackName = (String) metadata.get("trackName");
                    if (trackName == null) {
                        if (uri[0].endsWith("/")) {
                            uri[0] = uri[0].substring(0, uri[0].length() - 1);
                        }
                        trackName = uri[0].split("/")[uri[0].split("/").length - 1];
                        if (uri[0].toLowerCase().startsWith("file")) {
                            try {
                                trackName = URLDecoder.decode(trackName, StandardCharsets.UTF_8.toString());
                            } catch (UnsupportedEncodingException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                    String albumName = (String) metadata.get("albumName");
                    if (albumName == null) {
                        albumName = "Unknown Album";
                    }
                    String albumArtistName = (String) metadata.get("albumArtistName");
                    if (albumArtistName == null) {
                        albumArtistName = "Unknown Artist";
                    }
                    if (coverDirectory[0].endsWith("/")) {
                        coverDirectory[0] = coverDirectory[0].substring(0, coverDirectory[0].length() - 1);
                    }
                    final File file = new File(coverDirectory[0] + "/" + (trackName + albumName + albumArtistName + ".PNG").replaceAll("[\\\\/:*?\"\"<>| ]", ""));
                    try {
                        new File(coverDirectory[0]).mkdirs();
                        if (!file.exists()) {
                            file.createNewFile();
                        }
                        final FileOutputStream fileOutputStream = new FileOutputStream(file);
                        fileOutputStream.write(retriever.getEmbeddedPicture());
                        fileOutputStream.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    retriever.release();
                }
            });
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
