import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_challenge/app/bloc/app_bloc.dart';

@RoutePage()
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  static Widget transitionsBuilder(
    BuildContext ctx,
    Animation<double> anim1,
    Animation<double> anim2,
    Widget child,
  ) {
    return BackdropFilter(
      filter:
          ImageFilter.blur(sigmaX: 7 * anim1.value, sigmaY: 7 * anim1.value),
      child: Opacity(
        opacity: anim1.value,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingMessage = context.read<AppBloc>().state.loadingMessage;
    return Material(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: CircularProgressIndicator()),
          const SizedBox(
            height: 16,
          ),
          Text(
            loadingMessage ?? 'Loading...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
