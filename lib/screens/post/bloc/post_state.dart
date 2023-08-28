part of 'post_bloc.dart';

class PostState extends Equatable {
  const PostState({
    this.isEditMode = false,
    this.isEditing = false,
    this.isChanged = false,
    this.isUploading = false,
    this.isUploadSuccess = false,
    this.isLoadingNames = false,
    this.nameId = '',
    this.errorMessage = '',
    this.isLoading = false,
    this.activeName,
    this.editedName = '',
    this.resultNames = const [],
    this.chosenNames = const [],
  });
  final String errorMessage;
  final String nameId;
  final bool isLoading;
  final bool isEditMode;
  final bool isEditing;
  final bool isChanged;
  final bool isUploading;
  final bool isUploadSuccess;
  final bool isLoadingNames;
  final String? activeName;
  final String editedName;
  final List<({String orderNumber, String name})> resultNames;
  final List<({String orderNumber, String name})> chosenNames;

  bool get isNameChanged => activeName != editedName;
  bool get isNewName => editedName == 'new';

  PostState copyWith({
    String? nameId,
    String? errorMessage,
    bool? isLoading,
    bool? isEditMode,
    bool? isEditing,
    bool? isChanged,
    bool? isUploading,
    bool? isLoadingNames,
    bool? isUploadSuccess,
    String? activeName,
    String? editedName,
    List<({String orderNumber, String name})>? resultNames,
    List<({String orderNumber, String name})>? chosenNames,
  }) {
    return PostState(
      nameId: nameId ?? '',
      errorMessage: errorMessage ?? '',
      isLoading: isLoading ?? this.isLoading,
      isEditMode: isEditMode ?? this.isEditMode,
      isEditing: isEditing ?? this.isEditing,
      isChanged: isChanged ?? this.isChanged,
      isUploading: isUploading ?? this.isUploading,
      activeName: activeName ?? this.activeName,
      editedName: editedName ?? this.editedName,
      resultNames: resultNames ?? this.resultNames,
      chosenNames: chosenNames ?? this.chosenNames,
      isLoadingNames: isLoadingNames ?? this.isLoadingNames,
      isUploadSuccess: isUploadSuccess ?? this.isUploadSuccess,
    );
  }

  @override
  List<Object?> get props => [
        nameId,
        errorMessage,
        isLoading,
        isEditMode,
        isEditing,
        isChanged,
        isUploading,
        activeName,
        editedName,
        resultNames,
        chosenNames,
        isLoadingNames,
        isUploadSuccess,
      ];
}
