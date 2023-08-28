import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_challenge/app/view/loading_page.dart';
import 'package:photo_challenge/router/auth_guard.dart';
import 'package:photo_challenge/screens/admin_user_table/admin_user_table.dart';

import 'package:photo_challenge/screens/camera/camera.dart';
import 'package:photo_challenge/screens/landing/landing.dart';
import 'package:photo_challenge/screens/leaderboard/leaderboard.dart';
import 'package:photo_challenge/screens/post/view/post_page.dart';
import 'package:photo_challenge/screens/wall/wall.dart';

import 'package:photo_challenge/screens/wall_public/wall_public.dart';
import 'package:photo_challenge/screens/wall_self/wall_self.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: LandingRoute.page,
          guards: [AuthInputGuard()],
        ),
        AutoRoute(
          page: WallRoute.page,
          initial: true,
          guards: [AuthGuard()],
          children: [
            AutoRoute(page: WallPublicRoute.page),
            AutoRoute(page: WallSelfRoute.page),
          ],
        ),
        AutoRoute(
          page: PostRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: AdminUserTableRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: LeaderboardRoute.page,
          guards: [AuthGuard()],
        ),
        CustomRoute(
          page: LoadingRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: LoadingPage.transitionsBuilder,
          opaque: false,
        ),
        CustomRoute(
          guards: [AuthGuard()],
          page: CameraRoute.page,
          durationInMilliseconds: NeatTipTransitions.duration,
          opaque: false,
          fullscreenDialog: true,
          transitionsBuilder: NeatTipTransitions.slideFromBottom,
        ),
      ];
}

class NeatTipTransitions {
  static int duration = 600;

  static Widget slideFromBottom(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCirc,
          reverseCurve: Curves.easeInOut,
        ),
      ),
      child: child,
    );
  }
}
