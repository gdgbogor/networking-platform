part of 'app_bloc.dart';

class AppState extends Equatable {
  const AppState({
    required this.orderNumber,
    this.showLoadingOverlay = false,
    this.isAdmin = false,
    this.participantName,
    this.loadingMessage,
  });

  final bool showLoadingOverlay;
  final bool isAdmin;
  final String? loadingMessage;
  final String? participantName;
  final String orderNumber;

  AppState copyWith({
    bool? showLoadingOverlay,
    bool? isAdmin,
    String? loadingMessage,
    String? orderNumber,
    String? participantName,
  }) {
    return AppState(
      showLoadingOverlay: showLoadingOverlay ?? this.showLoadingOverlay,
      isAdmin: isAdmin ?? this.isAdmin,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      orderNumber: orderNumber ?? this.orderNumber,
      participantName: participantName ?? this.participantName,
    );
  }

  @override
  List<Object?> get props => [
        showLoadingOverlay,
        isAdmin,
        loadingMessage,
        orderNumber,
        participantName,
      ];
}
