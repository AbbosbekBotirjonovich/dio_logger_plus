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

  DioLogger({
    this.request = true,
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
    if (request) {
      _log('➡️ REQUEST → ${options.method} ${options.uri}');
    }
    if (requestHeader) {
      if (options.headers.isNotEmpty) {
        _printPrettyJson('🔸 Headers:', options.headers);
      } else {
        _log('🔸 Headers: {}');
      }
    }
    if (requestBody && options.data != null) {
      _printPrettyJson("📦 Body", options.data);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_debug) return super.onResponse(response, handler);

    if (responseBody && response.data != null) {
      _printPrettyJson("✅ RESPONSE:${response.requestOptions.uri}", response.data);
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_debug || !error) return super.onError(err, handler);

    _log('❌ ERROR ← ${err.requestOptions.uri}');
    _log('⛔️ Message: ${err.message}');
    if ((err.response?.data) != null) {
      _printPrettyJson("📛 Error Body", err.response?.data);
    }

    super.onError(err, handler);
  }

  void _printPrettyJson(String title, dynamic jsonObj) {
    try {
      final encoder = JsonEncoder.withIndent(compact ? '  ' : '    ');
      final pretty = encoder.convert(jsonObj);
      final lines = pretty.split('\n');
      final maxLength =
          lines.map((e) => e.length).reduce((current, next) => current > next ? current : next);
      final border = '=' * maxLength;
      final result = [
        border,
        ...lines.map((line) {
          var padLine = line.padRight(maxLength);
          return "|| $padLine ||";
        }),
        border,
      ].join('\n');
      _log('\n$result', title);
    } catch (e) {
      _log('$title: $jsonObj');
    }
  }

  void _log(String title, [String name = '']) => log(title, name: name);
}
