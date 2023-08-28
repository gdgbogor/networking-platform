part of 'wall_self_bloc.dart';

sealed class WallSelfEvent {
  const WallSelfEvent();
}

class LoadPhotos extends WallSelfEvent {
  const LoadPhotos({
    required this.participantName,
    required this.orderNumber,
  });

  final String orderNumber;
  final String participantName;
}

class LoadMorePhotos extends WallSelfEvent {
  const LoadMorePhotos({
    required this.participantName,
  });
  final String participantName;
}
