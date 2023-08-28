part of 'wall_public_bloc.dart';

class WallPublicState extends Equatable {
  const WallPublicState({
    this.photoList,
    this.newPhotoList,
    this.isLoading = true,
    this.hasNewPhotos = true,
    this.photoCount = 0,
    this.networkCount = 0,
  });

  final List<Image>? photoList;
  final List<Image>? newPhotoList;
  final bool isLoading;
  final bool hasNewPhotos;
  final int photoCount;
  final int networkCount;

  WallPublicState copyWith({
    List<Image>? photoList,
    List<Image>? newPhotoList,
    bool? isLoading,
    bool? hasNewPhotos,
    int? photoCount,
  }) {
    return WallPublicState(
      photoList: photoList ?? this.photoList,
      newPhotoList: newPhotoList ?? this.newPhotoList,
      isLoading: isLoading ?? this.isLoading,
      hasNewPhotos: hasNewPhotos ?? this.hasNewPhotos,
      photoCount: photoCount ?? this.photoCount,
    );
  }

  @override
  List<Object?> get props => [
        photoList,
        newPhotoList,
        isLoading,
        hasNewPhotos,
        photoCount,
      ];
}
