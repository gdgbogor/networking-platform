part of 'wall_self_bloc.dart';

class WallSelfState extends Equatable {
  const WallSelfState({
    this.photoList,
    this.newPhotoList,
    this.taggedList,
    this.isLoading = false,
    this.hasNewPhotos = true,
    this.photoCount = 0,
    this.networkCount = 0,
  });

  final List<Image>? photoList;
  final List<List<String>>? taggedList;
  final List<Image>? newPhotoList;
  final bool isLoading;
  final bool hasNewPhotos;
  final int photoCount;
  final int networkCount;

  WallSelfState copyWith({
    List<Image>? photoList,
    List<Image>? newPhotoList,
    List<List<String>>? taggedList,
    bool? isLoading,
    bool? hasNewPhotos,
    int? photoCount,
    int? networkCount,
  }) {
    return WallSelfState(
      photoList: photoList ?? this.photoList,
      taggedList: taggedList ?? this.taggedList,
      newPhotoList: newPhotoList ?? this.newPhotoList,
      isLoading: isLoading ?? this.isLoading,
      hasNewPhotos: hasNewPhotos ?? this.hasNewPhotos,
      photoCount: photoCount ?? this.photoCount,
      networkCount: networkCount ?? this.networkCount,
    );
  }

  @override
  List<Object?> get props => [
        photoList,
        taggedList,
        newPhotoList,
        isLoading,
        hasNewPhotos,
        photoCount,
        networkCount,
      ];
}
