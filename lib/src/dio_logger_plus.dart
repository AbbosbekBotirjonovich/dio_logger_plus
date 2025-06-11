import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioLoggerPlus extends InterceptorsWrapper {
  final bool requestHeader;
  final bool requestBody;
  final bool responseBody;
  final bool request;
  final bool error;
  final bool compact;
  final int maxWidth;
  final bool isOnlyDebug;

  DioLoggerPlus({
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
      _log('🔸 Headers: ${jsonEncode(options.headers)}');
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
    if (err.response?.data != null) {
      _printPrettyJson("📛 Error Body", err.response?.data);
    }

    super.onError(err, handler);
  }

  void _printPrettyJson(String title, dynamic jsonObj) {
    try {
      final encoder = JsonEncoder.withIndent(compact ? '  ' : '    ');
      final pretty = encoder.convert(jsonObj);
      _log('$title:\n$pretty');
    } catch (e) {
      _log('$title: $jsonObj');
    }
  }

  void _log(
    String title,
  ) =>
      log(title);
}
