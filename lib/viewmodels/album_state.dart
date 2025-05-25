import '../../models/album.dart';
import '../../models/photo.dart';

abstract class AlbumState {}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<Album> albums;
  final List<Photo> photos;

  AlbumLoaded(this.albums, this.photos);
}

class AlbumError extends AlbumState {
  final String message;
  AlbumError(this.message);
}
