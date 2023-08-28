part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();
  @override
  List<Object?> get props => [];
}

class AppInit extends AppEvent {
  const AppInit();
}

class AppSignOut extends AppEvent {
  const AppSignOut();
}

class AppEventToggleLoading extends AppEvent {
  const AppEventToggleLoading({
    this.message,
    this.isLoading,
  });

  final String? message;
  final bool? isLoading;
  @override
  List<Object?> get props => [message, isLoading];
}

class UpdateOrderNumber extends AppEvent {
  const UpdateOrderNumber({
    required this.orderNumber,
    required this.participantName,
    this.isAdmin = false,
  });

  final bool isAdmin;
  final String orderNumber;
  final String participantName;
  @override
  List<Object?> get props => [isAdmin, orderNumber, participantName];
}
