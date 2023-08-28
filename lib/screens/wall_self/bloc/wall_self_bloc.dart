// ignore_for_file: avoid_dynamic_calls

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'wall_self_event.dart';
part 'wall_self_state.dart';

class WallSelfBloc extends Bloc<WallSelfEvent, WallSelfState> {
  WallSelfBloc() : super(const WallSelfState()) {
    on<LoadPhotos>(_onLoadPhotos);
    on<LoadMorePhotos>(_onLoadMorePhotos);
  }

  final _firestore = FirebaseFirestore.instance;
  late Timestamp _lastPhoto;
  String? _orderNumber;

  Future<void> _onLoadPhotos(
    LoadPhotos event,
    Emitter<WallSelfState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    _orderNumber = event.orderNumber;
    log('_orderNumber $_orderNumber');
    // final query = _firestore
    //     .collection('photoList')
    //     .where('orderNumber', isEqualTo: _orderNumber)
    //     .orderBy('createdAt', descending: true)
    //     .limit(7);
    final networkQueryParameter = {
      'name': event.participantName,
      'orderNumber': _orderNumber,
    };
    log('networkQueryParameter $networkQueryParameter');
    final queryNetwork = _firestore
        .collection('photoList')
        // .where('orderNumber', isEqualTo: _orderNumber)
        .where(
          'taggedUserList',
          arrayContains: networkQueryParameter,
        )
        .orderBy('createdAt', descending: true)
        .limit(7);
    try {
      final snapshotNetwork = await queryNetwork.get();
      final photoList = <Image>[];
      final taggedList = <List<String>>[];
      final taggedAll = <String>{};
      if (snapshotNetwork.size > 0) {
        _lastPhoto = snapshotNetwork.docs.last.get('createdAt') as Timestamp;
        for (final doc in snapshotNetwork.docs) {
          log('taggedUserList ${doc.get('taggedUserList')}');
          final taggedUserList = doc.get('taggedUserList') as List<dynamic>;
          // final taggedUserList =
          //     doc.get('taggedUserList') as List<Map<String, dynamic>>;
          final photoUrl = doc.get('photoUrl') as String;
          // final fileName = doc.get('photoFileName') as String;
          try {
            // final downloadUrl =
            //     await _storage.ref('photo').child(fileName).getDownloadURL();
            final value = Image.network(photoUrl);
            photoList.add(value);
            taggedList.add(
              taggedUserList.map((e) => e['name'] as String).toList(),
            );
            taggedAll.addAll(
              taggedUserList.map((e) => e['orderNumber'] as String).toList(),
            );
          } catch (e) {
            // continue;
          }
        }

        emit(
          state.copyWith(
            photoCount: photoList.length,
            networkCount: taggedAll.isEmpty ? 0 : taggedAll.length - 1,
            photoList: photoList,
            taggedList: taggedList,
            isLoading: false,
          ),
        );
        final snapshot = await _firestore
            .collection('userList')
            .where('orderNumber', isEqualTo: _orderNumber)
            .get();

        await _firestore
            .collection('userList')
            .doc(snapshot.docs.first.id)
            .update(
          {
            'networkCount': taggedAll.isEmpty ? 0 : taggedAll.length - 1,
          },
        );
        return;
      }
      emit(
        state.copyWith(
          photoList: [],
          isLoading: false,
        ),
      );
    } catch (e) {
      log('e $e');
    }
  }

  Future<void> _onLoadMorePhotos(
    LoadMorePhotos event,
    Emitter<WallSelfState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final networkQueryParameter = {
      'name': event.participantName,
      'orderNumber': _orderNumber,
    };

    final queryNetwork = _firestore
        .collection('photoList')
        // .where('orderNumber', isEqualTo: _orderNumber)
        .where(
          'taggedUserList',
          arrayContains: networkQueryParameter,
        )
        .orderBy('createdAt', descending: true)
        .startAfter([_lastPhoto]).limit(7);
    final snapshot = await queryNetwork.get();
    final photoList = <Image>[];
    final taggedList = <List<String>>[];

    if (snapshot.size > 0) {
      _lastPhoto = snapshot.docs.last.get('createdAt') as Timestamp;
      for (final doc in snapshot.docs) {
        log('taggedUserList ${doc.get('taggedUserList')}');
        final taggedUserList = doc.get('taggedUserList') as List<dynamic>;
        // final taggedUserList =
        //     doc.get('taggedUserList') as List<Map<String, dynamic>>;
        final photoUrl = doc.get('photoUrl') as String;
        // final fileName = doc.get('photoFileName') as String;
        try {
          // final downloadUrl =
          //     await _storage.ref('photo').child(fileName).getDownloadURL();
          final value = Image.network(photoUrl);
          photoList.add(value);
          taggedList.add(
            taggedUserList.map((e) => e['name'] as String).toList(),
          );
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
          taggedList: [...state.taggedList!, ...taggedList],
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false, hasNewPhotos: false));
    }
  }
}
