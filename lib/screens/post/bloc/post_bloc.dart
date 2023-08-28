import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(const PostState()) {
    on<StartEditing>(_onStartEditing);
    on<ChooseName>(_onChooseName);
    on<RemoveName>(_onRemoveName);
    on<UploadPhoto>(_onUploadPhoto);
    on<EditName>(
      _onEditName,
      transformer: debounceRestartable(const Duration(milliseconds: 500)),
    );
  }

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  void _onStartEditing(
    StartEditing event,
    Emitter<PostState> emit,
  ) {
    emit(state.copyWith(isEditing: true, resultNames: []));
  }

  void _onChooseName(
    ChooseName event,
    Emitter<PostState> emit,
  ) {
    log('resultNames ${state.resultNames}');
    final choosenName = Set.of(state.chosenNames)
      ..add(
        state.resultNames.firstWhere(
          (participant) => participant.orderNumber == event.orderNumber,
        ),
      );
    emit(
      state.copyWith(chosenNames: choosenName.toList(), resultNames: []),
    );
  }

  void _onRemoveName(
    RemoveName event,
    Emitter<PostState> emit,
  ) {
    emit(
      state.copyWith(
        chosenNames: state.chosenNames
            .where(
              (participant) => participant.orderNumber != event.orderNumber,
            )
            .toList(),
      ),
    );
  }

  Future<void> _onEditName(
    EditName event,
    Emitter<PostState> emit,
  ) async {
    if (event.name.isEmpty) return;
    emit(
      state.copyWith(
        editedName: event.name,
        isEditing: false,
        isLoadingNames: true,
      ),
    );
    try {
      final query = _firestore
          .collection('taggedUserInfoList')
          .where('lowercaseName', arrayContains: event.name.toLowerCase());
      final snapshot = await query.get();
      final res = <({String orderNumber, String name})>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();

        res.add((orderNumber: data['orderNumber'], name: data['name']));
      }
      emit(state.copyWith(resultNames: res, isLoadingNames: false));
    } catch (e) {
      log('error: $e');
    }
  }

  Future<void> _onUploadPhoto(
    UploadPhoto event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(isUploading: true));
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${event.orderNumber}_$timeStamp';
    try {
      final storage = _storage.ref().child('photo/$fileName');
      await storage.putData(
        await event.photo.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final photoUrl = await storage.getDownloadURL();

      final ref = _firestore.collection('photoList');
      final data = {
        'createdAt': FieldValue.serverTimestamp(),
        'orderNumber': event.orderNumber,
        'photoUrl': photoUrl,
        'photoFileName': fileName,
        'taggedUserList': {
          (
            orderNumber: event.orderNumber,
            name: event.name,
          ),
          ...state.chosenNames
        }
            .map(
              (participant) => {
                'orderNumber': participant.orderNumber,
                'name': participant.name,
              },
            )
            .toList(),
      };
      log('data foto $data');
      await ref.add(data);
      emit(state.copyWith(isUploading: false, isUploadSuccess: true));
    } catch (e) {
      log('error: $e');
    }
  }

  EventTransformer<EditHashtagText> debounceRestartable<EditHashtagText>(
    Duration duration,
  ) {
    return (events, mapper) => restartable<EditHashtagText>()
        .call(events.debounceTime(duration), mapper);
  }
}
