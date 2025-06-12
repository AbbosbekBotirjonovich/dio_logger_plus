# DioLoggerPlus

[!![Pub](https://img.shields.io/badge/pub-v1.2.1-blue)](https://pub.dev/packages/dio_logger_plus)

**DioLoggerPlus** is a custom logging interceptor for the [Dio](https://pub.dev/packages/dio) HTTP client in Flutter. It helps developers easily debug
HTTP requests and responses by printing clean, formatted logs in the console.

---

## ✨ Features

- ✅ Logs HTTP requests and responses
- 📦 Pretty-prints request/response bodies
- 🔸 Logs request headers
- ❌ Logs errors with status and response body
- 🧩 Optional compact or indented JSON
- 🛠 Fully customizable
- 🔐 Supports debug-only logging (enabled via `kDebugMode`)

---

## 📦 Installation

Add `dio` to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.0.0
```

Then copy the DioLoggerPlus class into your project.

## 🚀 Usage

Add the interceptor to your Dio instance:

```
import 'package:dio/dio.dart';
import 'dio_logger_plus.dart'; // import your class

final dio = Dio();

dio.interceptors.add(DioLoggerPlus(
  request: true,
  requestHeader: true,
  requestBody: true,
  responseBody: true,
  error: true,
  compact: true,
  maxWidth: 90,
  isOnlyDebug: true,
));
```

---

## ⚙️ Configuration Options

| Parameter       | Type   | Default | Description                           |
|-----------------|--------|---------|---------------------------------------|
| `request`       | `bool` | `true`  | Logs HTTP method and URL              |
| `requestHeader` | `bool` | `true`  | Logs request headers                  |
| `requestBody`   | `bool` | `true`  | Logs request body                     |
| `responseBody`  | `bool` | `true`  | Logs response body                    |
| `error`         | `bool` | `true`  | Logs errors and error bodies          |
| `compact`       | `bool` | `true`  | Minimized JSON indentation            |
| `maxWidth`      | `int`  | `90`    | (Reserved) Max width of the log lines |
| `isOnlyDebug`   | `bool` | `true`  | Enables logging only in debug mode    |

---

## 🧪 Example Output

```
┌─────── 📤 REQUEST [2025-06-11 14:32:10] ───────
│ ➡️ GET https://api.example.com/user/123
│ 🔸 Headers:
│ {
│   "Authorization": "Bearer token123"
│ }
│ 📦 Body:
│ {
│   "email": "test@example.com"
│ }
└───────────────────────────────────────────────

┌────── ✅ RESPONSE (200 OK) [+123ms] ──────────
│ URL: https://api.example.com/user/123
│ 📦 Body:
│ {
│   "id": 123,
│   "name": "John Doe"
│ }
└───────────────────────────────────────────────

```

🔐 Debug-Only Logging

By default, logs are shown only in debug mode (kDebugMode).
To enable logs in release mode, set isOnlyDebug: false.