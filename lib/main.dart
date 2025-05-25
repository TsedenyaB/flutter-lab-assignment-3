import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'core/network/api_client.dart';
import 'viewmodels/album_bloc.dart';
import 'viewmodels/album_event.dart';
import 'routes/app_router.dart';

void main() {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    validateStatus: (status) {
      return status != null && status >= 200 && status < 300;
    },
  ));
  
  // Add logging interceptor with better error handling
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (object) {
      if (object.toString().contains('error') || object.toString().contains('exception')) {
        debugPrint('❌ $object');
      } else {
        debugPrint('✅ $object');
      }
    },
  ));

  // Add retry interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          try {
            return handler.resolve(await dio.fetch(error.requestOptions));
          } on DioException catch (e) {
            return handler.next(e);
          }
        }
        return handler.next(error);
      },
    ),
  );

  final apiClient = ApiClient(dio);
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  MyApp({required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlbumBloc(apiClient)..add(FetchAlbums()),
      child: MaterialApp.router(
        title: 'Album App',
        routerConfig: router,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
      ),
    );
  }
}
