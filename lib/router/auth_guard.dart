import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:photo_challenge/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    Future(
      () async {
        final sharedPreferences = await SharedPreferences.getInstance();
        final orderNumber = sharedPreferences.getString('orderNumber');
        if (orderNumber != null) {
          resolver.next();
        } else {
          unawaited(router.push(const LandingRoute()));
        }
      },
    );
  }
}

class AuthInputGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    Future(
      () async {
        final sharedPreferences = await SharedPreferences.getInstance();
        final orderNumber = sharedPreferences.getString('orderNumber');
        if (orderNumber == null) {
          resolver.next();
        } else {
          unawaited(router.push(const LandingRoute()));
        }
      },
    );
  }
}
