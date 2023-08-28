import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState(orderNumber: '')) {
    on<AppEventToggleLoading>(_onAppEventToggleLoading);
    on<AppInit>(_onAppInit);
    on<AppSignOut>(_onAppSignOut);
    on<UpdateOrderNumber>(_onUpdateOrderNumber);
  }

  late SharedPreferences _sharedPreferences;

  Future<void> _onAppInit(
    AppInit event,
    Emitter<AppState> emit,
  ) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    final orderNumber = _sharedPreferences.getString('orderNumber') ?? '';
    final participantName =
        _sharedPreferences.getString('participantName') ?? '';
    final isAdmin = _sharedPreferences.getBool('isAdmin') ?? false;
    log('AppBloc orderNumber $orderNumber');
    emit(
      state.copyWith(
        orderNumber: orderNumber,
        participantName: participantName,
        isAdmin: isAdmin,
      ),
    );
  }

  Future<void> _onAppSignOut(
    AppSignOut event,
    Emitter<AppState> emit,
  ) async {
    await _sharedPreferences.remove('orderNumber');
    await _sharedPreferences.remove('participantName');
    await _sharedPreferences.remove('isAdmin');
    emit(
      state.copyWith(orderNumber: '', participantName: '', isAdmin: false),
    );
  }

  void _onAppEventToggleLoading(
    AppEventToggleLoading event,
    Emitter<AppState> emit,
  ) {
    emit(
      state.copyWith(
        showLoadingOverlay: event.isLoading ?? !state.showLoadingOverlay,
        loadingMessage: event.message,
      ),
    );
  }

  Future<void> _onUpdateOrderNumber(
    UpdateOrderNumber event,
    Emitter<AppState> emit,
  ) async {
    final sharePref = await SharedPreferences.getInstance();
    await sharePref.setString('orderNumber', event.orderNumber);
    await sharePref.setString('participantName', event.participantName);
    await sharePref.setBool('isAdmin', event.isAdmin);
    emit(
      state.copyWith(
        orderNumber: event.orderNumber,
        participantName: event.participantName,
        isAdmin: event.isAdmin,
      ),
    );
  }
}
