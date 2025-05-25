import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'album_event.dart';
import 'album_state.dart';
import '../core/network/api_client.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final ApiClient apiClient;

  AlbumBloc(this.apiClient) : super(AlbumInitial()) {
    on<FetchAlbums>((event, emit) async {
      emit(AlbumLoading());
      try {
        final albums = await apiClient.getAlbums();
        final photos = await apiClient.getPhotos();
        if (albums.isEmpty) {
          emit(AlbumError('No albums found'));
        } else if (photos.isEmpty) {
          emit(AlbumError('No photos found'));
        } else {
          emit(AlbumLoaded(albums, photos));
        }
      } on DioException catch (e) {
        String errorMessage = 'Failed to load albums';
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Connection timeout. Please check your internet connection.';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'No internet connection. Please check your network.';
            break;
          case DioExceptionType.badResponse:
            errorMessage = 'Server error (${e.response?.statusCode}). Please try again later.';
            break;
          default:
            errorMessage = 'An unexpected error occurred. Please try again.';
        }
        emit(AlbumError(errorMessage));
      } catch (e) {
        emit(AlbumError('An unexpected error occurred: ${e.toString()}'));
      }
    });
  }
}
