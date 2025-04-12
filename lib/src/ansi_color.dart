sealed class AnsiColor {
  AnsiColor._();

  static const reset = '\\x1B[0m';
  static const red = '\\x1B[31m';
  static const green = '\\x1B[32m';
  static const yellow = '\\x1B[33m';
  static const blue = '\\x1B[34m';
  static const magenta = '\\x1B[35m';
  static const cyan = '\\x1B[36m';
  static const white = '\\x1B[37m';
  static const gray = '\\x1B[90m';

  static String wrap(String msg, String color) => '$color$msg$reset';
}
