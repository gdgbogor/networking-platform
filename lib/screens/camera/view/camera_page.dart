import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_challenge/router/app_router.dart';
import 'package:photo_challenge/shared/photo/photo_bloc.dart';

part './widgets/camera.dart';

@RoutePage()
class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CameraView();
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      movementDuration: const Duration(milliseconds: 700),
      key: const Key('scanner_vehicle_page'),
      direction: DismissDirection.down,
      onDismissed: (direction) {
        context.router.pop();
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -1),
              blurRadius: 10,
              color: Colors.black38,
            ),
          ],
        ),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: TextButton(
              child: const Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.red,
              ),
              onPressed: () {
                context.router.pop();
              },
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 300),
                children: [
                  const Center(child: _Camera()),
                  const SizedBox(height: 32),
                  Text(
                    'Panduan pengambilan foto yang baik',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ...[
                    '''Berkenalan terlebih dahulu peserta yang foto bersama kamu 🤝''',
                    'Pastikan wajah kamu dan kenalanmu terlihat jelas 👀',
                    'Cari pencahayaan yang cerah 🌤️',
                    'Gunakan latar belakang yang estetik 🌄',
                    'Bergaya dengan pose yang menarik ✌️',
                    'Jangan lupa senyum 😄',
                  ].asMap().entries.map(
                        (e) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade800,
                            child: Text('${e.key + 1}'),
                          ),
                          title: Text(e.value),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
