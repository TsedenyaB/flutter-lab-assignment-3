import 'package:go_router/go_router.dart';
import '../views/album_list_screen.dart';
import '../views/album_detail_screen.dart';
import '../models/album.dart';
import '../models/photo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/album_bloc.dart';
import '../viewmodels/album_state.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => AlbumListScreen(),
    ),
    GoRoute(
      path: '/album/:id',
      builder: (context, state) {
        final albumId = int.parse(state.pathParameters['id']!);
        
        // Get the current state from the bloc
        final albumState = context.read<AlbumBloc>().state;
        if (albumState is AlbumLoaded) {
          final album = albumState.albums.firstWhere(
            (a) => a.id == albumId,
            orElse: () => throw Exception('Album not found'),
          );
          final photo = albumState.photos.firstWhere(
            (p) => p.albumId == albumId,
            orElse: () => albumState.photos[0],
          );
          
          return AlbumDetailScreen(
            album: album,
            photo: photo,
          );
        }
        
        // If we don't have the data, show an error
        return AlbumDetailScreen.error(
          message: 'Album data not available',
          onRetry: () => context.go('/'),
        );
      },
    ),
  ],
);
