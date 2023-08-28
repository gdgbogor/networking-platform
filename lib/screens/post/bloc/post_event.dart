part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();
  @override
  List<Object?> get props => [];
}

class StartEditing extends PostEvent {
  const StartEditing();
}

class EditName extends PostEvent {
  const EditName({required this.name});

  final String name;
  @override
  List<Object?> get props => [name];
}

class ChooseName extends PostEvent {
  const ChooseName({required this.orderNumber});

  final String orderNumber;
  @override
  List<Object?> get props => [orderNumber];
}

class RemoveName extends PostEvent {
  const RemoveName({required this.orderNumber});

  final String orderNumber;
  @override
  List<Object?> get props => [orderNumber];
}

class UploadPhoto extends PostEvent {
  const UploadPhoto({
    required this.photo,
    required this.orderNumber,
    required this.name,
  });

  final XFile photo;
  final String orderNumber;
  final String name;

  @override
  List<Object?> get props => [photo, orderNumber, name];
}
