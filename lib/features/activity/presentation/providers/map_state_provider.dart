import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapViewState {
  general,
  shortRoute,
  longRoute,
}

class MapState {
  final MapViewState viewState;
  final String imagePath;

  MapState({
    required this.viewState,
    required this.imagePath,
  });

  MapState copyWith({
    MapViewState? viewState,
    String? imagePath,
  }) {
    return MapState(
      viewState: viewState ?? this.viewState,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class MapStateNotifier extends StateNotifier<MapState> {
  MapStateNotifier()
      : super(MapState(
          viewState: MapViewState.general,
          imagePath: 'images/map_preview_1.png',
        ));

  void cycleMap() {
    switch (state.viewState) {
      case MapViewState.general:
        state = state.copyWith(
          viewState: MapViewState.shortRoute,
          imagePath: 'images/map_preview_2.png',
        );
        break;
      case MapViewState.shortRoute:
        state = state.copyWith(
          viewState: MapViewState.longRoute,
          imagePath: 'images/map_preview_3.png',
        );
        break;
      case MapViewState.longRoute:
        state = state.copyWith(
          viewState: MapViewState.general,
          imagePath: 'images/map_preview_1.png',
        );
        break;
    }
  }

  void setViewState(MapViewState viewState) {
    String imagePath;
    switch (viewState) {
      case MapViewState.general:
        imagePath = 'images/map_preview_1.png';
        break;
      case MapViewState.shortRoute:
        imagePath = 'images/map_preview_2.png';
        break;
      case MapViewState.longRoute:
        imagePath = 'images/map_preview_3.png';
        break;
    }
    state = state.copyWith(viewState: viewState, imagePath: imagePath);
  }
}

final mapStateProvider = StateNotifierProvider<MapStateNotifier, MapState>((ref) {
  return MapStateNotifier();
});
