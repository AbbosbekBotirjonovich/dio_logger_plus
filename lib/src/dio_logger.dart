import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioLogger extends InterceptorsWrapper {
  final bool requestHeader;
  final bool requestBody;
  final bool responseBody;
  final bool request;
  final bool error;
  final bool compact;
  final int maxWidth;
  final bool isOnlyDebug;
  final bool showTimestamp;

  DioLogger({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseBody = true,
    this.error = true,
    this.compact = true,
    this.maxWidth = 90,
    this.isOnlyDebug = true,
    this.showTimestamp = true,
  });

  bool get _debug => isOnlyDebug ? kDebugMode : true;
  final Map<Uri, DateTime> _requestStartTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_debug) return super.onRequest(options, handler);

    _requestStartTimes[options.uri] = DateTime.now();

    final timestamp = showTimestamp ? '[🕒 ${DateTime.now()}]' : '';
    final buffer = StringBuffer('\n');

    buffer.writeln('┌─────── 📤 REQUEST $timestamp ───────');
    buffer.writeln('│ ➡️ ${options.method} ${options.uri}');

    if (requestHeader) {
      buffer.writeln('│ 🔸 Headers:');
      buffer.writeln(_indentJson(options.headers));
    }

    if (requestBody && options.data != null) {
      buffer.writeln('│ 📦 Body:');
      buffer.writeln(_indentJson(options.data));
    }

    buffer.writeln('└───────────────────────────────────────────────');
    _log(buffer.toString());

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_debug) return super.onResponse(response, handler);

    final start = _requestStartTimes.remove(response.requestOptions.uri);
    final duration = start != null ? DateTime.now().difference(start).inMilliseconds : null;

    final buffer = StringBuffer('\n');
    buffer
        .writeln('┌────── ✅ RESPONSE (${response.statusCode}) [+${duration ?? '?'}ms] ──────────');
    buffer.writeln('│ URL: ${response.requestOptions.uri}');

    if (responseBody && response.data != null) {
      buffer.writeln('│ 📦 Body:');
      buffer.writeln(_indentJson(response.data));
    }

    buffer.writeln('└───────────────────────────────────────────────');
    _log(buffer.toString());

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_debug || !error) return super.onError(err, handler);

    final buffer = StringBuffer('\n');
    buffer.writeln('┌────── ❌ ERROR ───────');
    buffer.writeln('│ URL: ${err.requestOptions.uri}');
    buffer.writeln('│ ⛔️ Message: ${err.message}');

    if ((err.response?.data) != null) {
      buffer.writeln('│ 📛 Body:');
      buffer.writeln(_indentJson(err.response?.data));
    }

    buffer.writeln('└──────────────────────');
    _log(buffer.toString());

    super.onError(err, handler);
  }

  String _indentJson(dynamic jsonObj) {
    try {
      final encoder = JsonEncoder.withIndent(compact ? '  ' : '    ');
      final pretty = encoder.convert(jsonObj);
      return pretty.split('\n').map((line) => '│ $line').join('\n');
    } catch (e) {
      return '│ $jsonObj';
    }
  }

  void _log(String message) => log(message, name: 'Dio Logger');
}
