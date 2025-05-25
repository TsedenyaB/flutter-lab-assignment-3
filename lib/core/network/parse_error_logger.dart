import 'package:dio/dio.dart';

class ParseErrorLogger {
  void logError(Object error, StackTrace stackTrace, RequestOptions requestOptions) {
    // You can implement your error logging logic here
    // For example, you could log to a file, send to a logging service, etc.
    print('Error occurred: $error');
    print('Stack trace: $stackTrace');
    print('Request URL: ${requestOptions.uri}');
    print('Request method: ${requestOptions.method}');
  }
} 