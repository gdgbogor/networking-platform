import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'wall_public_event.dart';
part 'wall_public_state.dart';

class WallPublicBloc extends Bloc<WallPublicEvent, WallPublicState> {
  WallPublicBloc() : super(const WallPublicState()) {
    on<LoadPhotos>(_onLoadPhotos);
    on<LoadMorePhotos>(_onLoadMorePhotos);
    on<DeletePhoto>(_onDeletePhoto);
  }

  final _firestore = FirebaseFirestore.instance;
  late Timestamp _lastPhoto;
  final _photoIds = <String>[];

  Future<void> _onLoadPhotos(
    LoadPhotos event,
    Emitter<WallPublicState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final query = _firestore
          .collection('photoList')
          .orderBy('createdAt', descending: true)
          .limit(15);
      final snapshot = await query.get();
      if (snapshot.size > 0) {
        final photoList = <Image>[];
        _lastPhoto = snapshot.docs.last.get('createdAt') as Timestamp;
        for (final doc in snapshot.docs) {
          final photoUrl = doc.get('photoUrl') as String;
          // final fileName = doc.get('photoFileName') as String;
          try {
            // final downloadUrl =
            //     await _storage.ref('photo').child(fileName).getDownloadURL();
            final value = Image.network(photoUrl);
            photoList.add(value);
            _photoIds.add(doc.id);
          } catch (e) {
            // continue;
          }
        }
        log('wkwkwkwk ${{
          'photoCount': snapshot.size,
          'photoList': photoList,
          'isLoading': false,
        }}');
        emit(
          state.copyWith(
            photoCount: snapshot.size,
            photoList: photoList,
            isLoading: false,
          ),
        );
        return;
      } else {
        emit(
          state.copyWith(isLoading: false, photoList: []),
        );
      }
    } catch (e) {
      log('error: $e');
    }
  }

  Future<void> _onLoadMorePhotos(
    LoadMorePhotos event,
    Emitter<WallPublicState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final query = _firestore
        .collection('photoList')
        .orderBy('createdAt', descending: true)
        .startAfter([_lastPhoto]).limit(15);

    final snapshot = await query.get();
    final photoList = <Image>[];
    if (snapshot.size > 0) {
      _lastPhoto = snapshot.docs.last.get('createdAt') as Timestamp;
      for (final doc in snapshot.docs) {
        final photoUrl = doc.get('photoUrl') as String;
        // final fileName = doc.get('photoFileName') as String;
        try {
          // final downloadUrl =
          //     await _storage.ref('photo').child(fileName).getDownloadURL();
          final value = Image.network(photoUrl);
          photoList.add(value);
          _photoIds.add(doc.id);
        } catch (e) {
          // continue;
        }
      }
      emit(
        state.copyWith(
          photoCount: state.photoCount + photoList.length,
          photoList: [...state.photoList!, ...photoList],
          isLoading: false,
          hasNewPhotos: true,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false, hasNewPhotos: false));
    }
  }

  Future<void> _onDeletePhoto(
    DeletePhoto event,
    Emitter<WallPublicState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final newPhotoList = [...state.photoList!];
      await _firestore
          .collection('photoList')
          .doc(_photoIds[event.photoIndex])
          .delete();
      newPhotoList.removeAt(event.photoIndex);
      _photoIds.removeAt(event.photoIndex);
      emit(
        state.copyWith(
          isLoading: true,
          photoList: newPhotoList,
          photoCount: state.photoCount - 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasNewPhotos: false));
    }

    // final snapshot = await query.get();
    // final photoList = <Image>[];
    // if (snapshot.size > 0) {
    //   _lastPhoto = snapshot.docs.last.get('createdAt') as Timestamp;
    //   for (final doc in snapshot.docs) {
    //     final photoUrl = doc.get('photoUrl') as String;
    //     // final fileName = doc.get('photoFileName') as String;
    //     try {
    //       // final downloadUrl =
    //       //     await _storage.ref('photo').child(fileName).getDownloadURL();
    //       final value = Image.network(photoUrl);
    //       photoList.add(value);
    //     } catch (e) {
    //       // continue;
    //     }
    //   }
    //   emit(
    //     state.copyWith(
    //       photoCount: state.photoCount + photoList.length,
    //       photoList: [...state.photoList!, ...photoList],
    //       isLoading: false,
    //       hasNewPhotos: true,
    //     ),
    //   );
    // } else {
    //   emit(state.copyWith(isLoading: false, hasNewPhotos: false));
    // }
  }
}
