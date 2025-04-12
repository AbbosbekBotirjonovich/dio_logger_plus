import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'ansi_color.dart';

class DioLoggerPlus extends InterceptorsWrapper {
  final bool requestHeader;
  final bool requestBody;
  final bool responseBody;
  final bool error;
  final bool compact;
  final int maxWidth;
  final bool isOnlyDebug;

  DioLoggerPlus({
    this.requestHeader = true,
    this.requestBody = true,
    this.responseBody = true,
    this.error = true,
    this.compact = true,
    this.maxWidth = 90,
    this.isOnlyDebug = true,
  });

  bool get _debug => isOnlyDebug ? kDebugMode : true;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_debug) return super.onRequest(options, handler);

    _log('➡️ REQUEST → ${options.method} ${options.uri}', color: AnsiColor.blue);
    if (requestHeader) {
      _log('🔸 Headers: ${jsonEncode(options.headers)}', color: AnsiColor.gray);
    }

    if (requestBody && options.data != null) {
      _printPrettyJson("📦 Body", options.data);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_debug) return super.onResponse(response, handler);

    _log('✅ RESPONSE ← ${response.statusCode} ${response.requestOptions.uri}',
        color: AnsiColor.green);
    if (responseBody && response.data != null) {
      _printPrettyJson("📩 Response", response.data);
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_debug || !error) return super.onError(err, handler);

    _log('❌ ERROR ← ${err.requestOptions.uri}', color: AnsiColor.red);
    _log('⛔️ Message: ${err.message}', color: AnsiColor.magenta);
    if (err.response?.data != null) {
      _printPrettyJson("📛 Error Body", err.response?.data);
    }

    super.onError(err, handler);
  }

  void _printPrettyJson(String title, dynamic jsonObj) {
    try {
      final encoder = JsonEncoder.withIndent(compact ? '  ' : '    ');
      final pretty = encoder.convert(jsonObj);
      _log('$title:\n$pretty', color: AnsiColor.cyan);
    } catch (e) {
      _log('$title: $jsonObj');
    }
  }

  void _log(String message, {String? color}) {
    final content = color != null ? AnsiColor.wrap(message, color) : message;
    for (var line in _chunk(content)) {
      debugPrint(line);
    }
  }

  List<String> _chunk(String msg) {
    final lines = <String>[];
    final len = msg.length;
    for (var i = 0; i < len; i += maxWidth) {
      lines.add(msg.substring(i, i + maxWidth > len ? len : i + maxWidth));
    }
    return lines;
  }
}
