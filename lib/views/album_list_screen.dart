import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/album_bloc.dart';
import '../viewmodels/album_state.dart';
import '../viewmodels/album_event.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AlbumListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Photo Albums",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            if (state is AlbumLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading albums...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AlbumError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[400],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AlbumBloc>().add(FetchAlbums()),
                      icon: Icon(Icons.refresh),
                      label: Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AlbumLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AlbumBloc>().add(FetchAlbums());
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.albums.length,
                  itemBuilder: (context, index) {
                    final album = state.albums[index];
                    final photo = state.photos.firstWhere(
                      (p) => p.albumId == album.id,
                      orElse: () => state.photos[0],
                    );
                    
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Hero(
                        tag: 'album_${album.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Card(
                            elevation: 4,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.go('/album/${album.id}'),
                              child: Container(
                                height: 120,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(16),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: photo.thumbnailUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(milliseconds: 300),
                                        fadeOutDuration: Duration(milliseconds: 300),
                                        placeholder: (context, url) => Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) {
                                          print('Error loading image: $error');
                                          return GestureDetector(
                                            onTap: () {
                                              CachedNetworkImage.evictFromCache(photo.thumbnailUrl);
                                              (context as Element).markNeedsBuild();
                                            },
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.horizontal(
                                                  left: Radius.circular(16),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.error_outline,
                                                    color: Colors.red[400],
                                                    size: 32,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Tap to retry',
                                                    style: TextStyle(
                                                      color: Colors.red[400],
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              album.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    'Album #${album.id}',
                                                    style: TextStyle(
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Spacer(),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 16,
                                                  color: Colors.grey[400],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }
}
