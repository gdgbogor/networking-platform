import 'package:photo_challenge/app/app.dart';
import 'package:photo_challenge/bootstrap.dart';
import 'package:photo_challenge/flavor_config.dart';

void main() {
  bootstrap(
    () => const App(),
    Environment.production,
  );
}
