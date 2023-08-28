part of 'photo_bloc.dart';

class PhotoState extends Equatable {
  const PhotoState({this.capturedImage});

  final XFile? capturedImage;

  PhotoState copyWith({
    XFile? capturedImage,
  }) {
    return PhotoState(
      capturedImage: capturedImage ?? this.capturedImage,
    );
  }

  @override
  List<Object?> get props => [capturedImage];
}
