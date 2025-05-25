import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import '../../models/album.dart';
import '../../models/photo.dart';
import 'parse_error_logger.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://jsonplaceholder.typicode.com")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) {
    dio.options.validateStatus = (status) {
      return status != null && status >= 200 && status < 300;
    };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Request URL: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          print('Response status: ${response.statusCode}');
          // Replace placeholder image URLs with working ones from picsum.photos
          if (response.requestOptions.path == '/photos' &&
              response.data is List) {
            final List<dynamic> photos = response.data;
            for (int i = 0; i < photos.length; i++) {
              if (photos[i] is Map) {
                final Map<String, dynamic> photo = photos[i];
                if (photo.containsKey('id')) {
                  // Generate a unique seed for each photo based on multiple properties
                  final seed = '${photo['albumId']}-${photo['id']}';
                  photo['url'] = 'https://jsonplaceholder.typicode.com/albums';
                  photo['thumbnailUrl'] =
                      'https://jsonplaceholder.typicode.com/photos';
                }
              }
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Error: ${e.message}');
          print('Error type: ${e.type}');
          print('Error response: ${e.response}');
          return handler.next(e);
        },
      ),
    );

    return _ApiClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  @GET("/albums")
  Future<List<Album>> getAlbums();

  @GET("/photos")
  Future<List<Photo>> getPhotos();
}
