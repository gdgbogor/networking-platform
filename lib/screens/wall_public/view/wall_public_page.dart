import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_challenge/app/app.dart';

import 'package:photo_challenge/screens/wall_public/wall_public.dart';

@RoutePage()
class WallPublicPage extends StatelessWidget {
  const WallPublicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WallPublicBloc()..add(const LoadPhotos()),
      child: const _WallPublicView(),
    );
  }
}

class _WallPublicView extends StatefulWidget {
  const _WallPublicView();

  @override
  State<_WallPublicView> createState() => _WallPublicViewState();
}

class _WallPublicViewState extends State<_WallPublicView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        context.read<WallPublicBloc>().add(const LoadMorePhotos());
      }
    });
  }

  void _promptDelete(int index) {
    final wallBloc = context.read<WallPublicBloc>();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus foto'),
          content: const Text('Apakah kamu yakin ingin menghapus foto ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            BlocListener<WallPublicBloc, WallPublicState>(
              bloc: wallBloc,
              listenWhen: (previous, current) =>
                  previous.photoCount != current.photoCount,
              listener: (context, state) {
                Future.delayed(const Duration(seconds: 1), () {
                  context.read<AppBloc>().add(
                        const AppEventToggleLoading(
                          isLoading: false,
                        ),
                      );
                  context.router.pop();
                });
              },
              child: TextButton(
                onPressed: () {
                  context.read<AppBloc>().add(
                        const AppEventToggleLoading(
                          isLoading: true,
                          message: 'Menghapus foto',
                        ),
                      );
                  wallBloc.add(DeletePhoto(photoIndex: index));
                },
                child: const Text('Hapus'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: BlocBuilder<WallPublicBloc, WallPublicState>(
          builder: (context, state) {
            final photoList = state.photoList;
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<WallPublicBloc>().add(const LoadPhotos());
                  final stream = context.read<WallPublicBloc>().stream;
                  return stream
                      .firstWhere((WallPublicState state) => !state.isLoading)
                      .then((state) => !state.isLoading);
                },
                notificationPredicate: (notification) {
                  return notification.depth == 0;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 48),
                  controller: _scrollController,
                  child: StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: List.generate(
                      photoList == null ? 2 : photoList.length + 2,
                      (index) {
                        if (index == 0) {
                          return StaggeredGridTile.fit(
                            crossAxisCellCount: 2,
                            child: AspectRatio(
                              aspectRatio: 1.5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/photo%2FGOOGA12345678_1692421227823?alt=media&token=05019033-f191-4115-a67a-0f6ed08487d1',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const Positioned.fill(
                                      child: ColoredBox(color: Colors.black38),
                                    ),
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '''BUAT KENALAN BARU\nLEBIH BERKESAN''',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '''Perbanyak network\ndan menangkan swags!''',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        if (photoList == null ||
                            index == photoList.length + 1) {
                          return StaggeredGridTile.fit(
                            crossAxisCellCount: 2,
                            child: SizedBox(
                              height: 100,
                              child: Center(
                                child: AnimatedCrossFade(
                                  crossFadeState:
                                      state.isLoading && photoList == null
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                  firstChild: Text(
                                    !state.isLoading && photoList!.isEmpty
                                        ? 'Mulai post foto bersama kamu'
                                        : state.hasNewPhotos
                                            ? 'Lihat lagi... 👀'
                                            : 'Ayo post foto lagi',
                                    // 'wkwks',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  secondChild: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  sizeCurve: Curves.easeInOutExpo,
                                  duration: const Duration(milliseconds: 300),
                                ),
                              ),
                            ),
                          );
                        }
                        final photo = photoList.elementAt(index - 1);
                        return StaggeredGridTile.fit(
                          crossAxisCellCount: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onLongPress:
                                  !context.read<AppBloc>().state.isAdmin
                                      ? null
                                      : () => _promptDelete(index - 1),
                              child: Image(
                                image: photo.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
