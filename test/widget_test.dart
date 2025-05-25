// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:album_app/main.dart';
import 'package:album_app/core/network/api_client.dart';
import 'package:album_app/viewmodels/album_bloc.dart';
import 'package:album_app/viewmodels/album_state.dart';
import 'package:album_app/viewmodels/album_event.dart';
import 'package:album_app/models/album.dart';
import 'package:album_app/models/photo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:album_app/views/album_list_screen.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockAlbumBloc extends MockBloc<AlbumEvent, AlbumState> implements AlbumBloc {
  @override
  AlbumState get state => super.state;
}

void main() {
  late MockApiClient mockApiClient;
  late MockAlbumBloc mockAlbumBloc;

  setUp(() {
    mockApiClient = MockApiClient();
    mockAlbumBloc = MockAlbumBloc();
    registerFallbackValue(FetchAlbums());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AlbumBloc>.value(
        value: mockAlbumBloc,
        child: AlbumListScreen(),
      ),
    );
  }

  testWidgets('Album app shows loading state initially', (WidgetTester tester) async {
    // Arrange
    when(() => mockAlbumBloc.state).thenReturn(AlbumLoading());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Album app shows error state with retry button', (WidgetTester tester) async {
    // Arrange
    const errorMessage = 'Failed to load albums';
    when(() => mockAlbumBloc.state).thenReturn(AlbumError(errorMessage));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Test retry functionality
    await tester.tap(find.text('Retry'));
    await tester.pump();
    verify(() => mockAlbumBloc.add(any<FetchAlbums>())).called(1);
  });

  testWidgets('Album app shows albums when loaded', (WidgetTester tester) async {
    // Arrange
    final albums = [
      Album(id: 1, userId: 1, title: 'Test Album 1'),
      Album(id: 2, userId: 1, title: 'Test Album 2'),
    ];
    final photos = [
      Photo(id: 1, albumId: 1, title: 'Test Photo 1', url: 'https://example.com/1.jpg', thumbnailUrl: 'https://example.com/thumb1.jpg'),
      Photo(id: 2, albumId: 2, title: 'Test Photo 2', url: 'https://example.com/2.jpg', thumbnailUrl: 'https://example.com/thumb2.jpg'),
    ];
    when(() => mockAlbumBloc.state).thenReturn(AlbumLoaded(albums, photos));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text('Test Album 1'), findsOneWidget);
    expect(find.text('Test Album 2'), findsOneWidget);
    expect(find.text('Album #1'), findsOneWidget);
    expect(find.text('Album #2'), findsOneWidget);
  });
}
