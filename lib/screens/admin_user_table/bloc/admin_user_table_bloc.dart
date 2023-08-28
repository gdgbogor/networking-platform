import 'package:bloc/bloc.dart';

part 'admin_user_table_event.dart';
part 'admin_user_table_state.dart';

class AdminUserTableBloc
    extends Bloc<AdminUserTableEvent, AdminUserTableState> {
  AdminUserTableBloc() : super(const AdminUserTableState()) {
    on<AdminUserTableEvent>((event, emit) {
      //
    });
  }
}
