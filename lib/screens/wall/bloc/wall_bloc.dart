import 'package:bloc/bloc.dart';

part 'wall_event.dart';
part 'wall_state.dart';

class WallBloc extends Bloc<WallEvent, WallState> {
  WallBloc() : super(const WallState()) {
    on<WallEvent>((event, emit) {
      //
    });
  }
}
