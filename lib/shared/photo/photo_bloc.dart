import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

part 'photo_event.dart';
part 'photo_state.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc() : super(const PhotoState()) {
    on<PhotoEvent>((event, emit) {
      //
    });
    on<PhotoEventSave>(_onPhotoEventSave);
  }

  Future<void> _onPhotoEventSave(
    PhotoEventSave event,
    Emitter<PhotoState> emit,
  ) async {
    emit(state.copyWith(capturedImage: event.image));
  }
}
