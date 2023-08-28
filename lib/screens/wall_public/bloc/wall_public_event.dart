part of 'wall_public_bloc.dart';

sealed class WallPublicEvent {
  const WallPublicEvent();
}

class LoadPhotos extends WallPublicEvent {
  const LoadPhotos();
}

class LoadMorePhotos extends WallPublicEvent {
  const LoadMorePhotos();
}

class DeletePhoto extends WallPublicEvent {
  const DeletePhoto({
    required this.photoIndex,
  });
  final int photoIndex;
}
