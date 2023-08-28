import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_challenge/app/app.dart';
import 'package:photo_challenge/router/app_router.dart';
import 'package:photo_challenge/screens/wall/wall.dart';

@RoutePage()
class WallPage extends StatelessWidget {
  const WallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WallBloc(),
      child: const WallView(),
    );
  }
}

class WallView extends StatelessWidget {
  const WallView({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [WallPublicRoute(), WallPublicRoute(), WallSelfRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            forceMaterialTransparency: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.red.shade800,
            title: Row(
              children: [
                CachedNetworkImage(
                  width: 36,
                  height: 36,
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2F1_v0LmFs2Uvc8DJQyKXb0qWw%402x.png?alt=media&token=44bd17d0-0801-41b0-9ce6-bf77356803fa',
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                const SizedBox(width: 16),
                CachedNetworkImage(
                  width: 36,
                  height: 36,
                  imageUrl:
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Keras_logo.svg/360px-Keras_logo.svg.png',
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                const SizedBox(width: 16),
                const Text(' Network Challenge'),
              ],
            ),
            actions: [
              if (context.read<AppBloc>().state.isAdmin)
                IconButton(
                  onPressed: () {
                    context.router.push(const AdminUserTableRoute());
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Admin',
                ),
              BlocListener<AppBloc, AppState>(
                listenWhen: (previous, current) => current.orderNumber.isEmpty,
                listener: (context, state) {
                  Future.delayed(const Duration(seconds: 1), () {
                    context.read<AppBloc>().add(
                          const AppEventToggleLoading(
                            isLoading: false,
                          ),
                        );
                    context.router.replace(const LandingRoute());
                  });
                },
                child: IconButton(
                  onPressed: () {
                    context.read<AppBloc>().add(
                          const AppEventToggleLoading(
                            isLoading: true,
                            message: 'Mengeluarkan anda',
                          ),
                        );
                    context.read<AppBloc>().add(const AppSignOut());
                  },
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign out',
                ),
              ),
            ],
          ),

          // bottomNavigationBar: ConstrainedBox(
          //   constraints: const BoxConstraints(maxWidth: 300),
          //   child: BottomNavigationBar(
          //     currentIndex: tabsRouter.activeIndex,
          //     onTap: tabsRouter.setActiveIndex,
          //     items: const [
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.public),
          //         label: 'Umum',
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.add),
          //         label: '',
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.person),
          //         label: 'Pribadi',
          //       ),
          //     ],
          //   ),
          // ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.router.push(const CameraRoute());
            },
            backgroundColor: Colors.red.shade800,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 32),
            // elevation: 0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                {
                  'Umum': {Icons.public: Icons.public}
                },
                {
                  'Post': {Icons.square_outlined: Icons.square}
                },
                {
                  'Profil': {Icons.person: Icons.person_outline}
                },
              ].asMap().entries.map((entry) {
                return SizedBox(
                  width: 100,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: entry.key == 1
                        ? null
                        : () {
                            tabsRouter.setActiveIndex(entry.key);
                          },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (entry.key == 1)
                          const SizedBox(
                            height: 28,
                          )
                        else
                          Icon(
                            tabsRouter.activeIndex == entry.key
                                ? entry.value.values.first.keys.first
                                : entry.value.values.first.values.first,
                            color: tabsRouter.activeIndex == entry.key
                                ? Colors.red.shade700
                                : Colors.grey.shade400,
                          ),
                        Text(
                          entry.value.keys.first,
                          style: TextStyle(
                            fontSize: 12,
                            color: tabsRouter.activeIndex == entry.key
                                ? Colors.red.shade900
                                : Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          body: child,
        );
      },
    );
  }
}
