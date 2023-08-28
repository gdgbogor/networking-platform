import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_challenge/app/app.dart';
import 'package:photo_challenge/l10n/l10n.dart';
import 'package:photo_challenge/router/app_router.dart';
import 'package:photo_challenge/screens/wall_self/wall_self.dart';
import 'package:photo_challenge/shared/photo/photo_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appBloc = AppBloc()..add(const AppInit());
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => appBloc,
        ),
        BlocProvider(
          create: (_) => PhotoBloc(),
        ),
        BlocProvider(
          create: (_) => WallSelfBloc(),
        ),
      ],
      child: _App(),
    );
  }
}

class _App extends StatelessWidget {
  _App();
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MaterialApp.router(
      theme: _buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // routerConfig: appRouter.config(),
      routerConfig: appRouter.config(
        navigatorObservers: () => [AutoRouteObserver()],
      ),

      builder: (context, child) {
        return Title(
          title: 'KCD Network Challenge',
          color: Colors.red.shade800,
          child: _AppState(
            appRouter: appRouter,
            child: child,
          ),
        );
      },
      // routeInformationParser: appRouter.defaultRouteParser(),
      // routerDelegate: appRouter.delegate(
      // navigatorObservers: () => <NavigatorObserver>[AutoRouteObserver()]),
    );
  }
}

class _AppState extends StatelessWidget {
  const _AppState({
    required this.appRouter,
    this.child,
  });

  final Widget? child;
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) {
        return previous.showLoadingOverlay != current.showLoadingOverlay;
      },
      listener: (context, state) {
        if (state.showLoadingOverlay) {
          appRouter.push(const LoadingRoute());
        } else {
          appRouter.pop();
        }
      },
      child: child,
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final baseTheme = ThemeData(
    brightness: brightness,
    appBarTheme: AppBarTheme(color: Colors.red.shade800, elevation: 0),
    primaryColor: Colors.red.shade400,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Colors.red.shade400,
      secondary: Colors.red.shade400,
    ),
  );

  return baseTheme.copyWith(
    textTheme: GoogleFonts.nunitoSansTextTheme(
      baseTheme.textTheme,
    ),
  );
}
