part of 'photo_bloc.dart';

sealed class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object> get props => [];
}

class PhotoEventSave extends PhotoEvent {
  const PhotoEventSave(this.image);

  final XFile image;

  @override
  List<Object> get props => [image];
}
